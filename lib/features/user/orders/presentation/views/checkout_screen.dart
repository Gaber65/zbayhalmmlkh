import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/domain/entities/cart.dart';
import 'package:dhabayih_lmamlaka/features/user/address/presentation/manager/address_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/address/presentation/manager/address_state.dart';
import 'package:dhabayih_lmamlaka/features/user/address/domain/entities/address_entity.dart';
import 'package:dhabayih_lmamlaka/features/user/address/domain/services/fulfillment_service.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/profile_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/profile_state.dart';
import '../manager/checkout_cubit.dart';
import '../manager/checkout_state.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/branch_entity.dart';
import 'package:dhabayih_lmamlaka/core/payment/payment_service.dart';
import 'package:dhabayih_lmamlaka/core/payment/payment_request.dart';
import 'package:dhabayih_lmamlaka/core/payment/payment_status.dart';

class CheckoutScreen extends StatefulWidget {
  final CartEntity cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  bool _redeemPoints = false;
  bool _isPickup = false;
  AddressEntity? _selectedAddress;
  List<BranchEntity> _branches = [];
  BranchEntity? _selectedBranch;
  bool _loadingBranches = false;
  List<PaymentMethodEntity> _paymentMethods = [];
  PaymentMethodEntity? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _loadFulfillmentSettings();
    _loadBranches();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadFulfillmentSettings() async {
    final isPickup = await FulfillmentService.isStorePickup();
    if (mounted) {
      setState(() {
        _isPickup = isPickup;
      });
    }
  }

  Future<void> _loadBranches() async {
    setState(() => _loadingBranches = true);
    CheckoutCubit cubit;
    try {
      cubit = context.read<CheckoutCubit>();
    } catch (_) {
      cubit = getIt<CheckoutCubit>();
    }
    final branches = await cubit.getBranches();
    if (mounted) {
      setState(() {
        _branches = branches;
        if (branches.isNotEmpty && _selectedBranch == null) {
          _selectedBranch = branches.first;
        }
        _loadingBranches = false;
      });
    }
  }

  void _confirmAndPlaceOrder(BuildContext context) {
    if (widget.cart.lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السلة فارغة، يرجى إضافة منتجات أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_isPickup && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).addr_select_address),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isPickup && _selectedBranch == null && _branches.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار فرع الاستلام للمتابعة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<CheckoutCubit>().checkout(
      deliveryType: _isPickup ? 'pickup' : 'address',
      addressId: _isPickup ? null : _selectedAddress?.id,
      branchId: _isPickup ? (_selectedBranch?.id ?? 1) : null,
      paymentMethodId:
          _selectedPaymentMethod?.id ?? 1, // Dynamic payment method
      notes: _notesController.text.trim(),
      couponCode: _couponController.text.trim(),
      redeemPoints: _redeemPoints,
    );
  }

  bool _isLoadingShowing = false;

  void _showLoadingDialog(BuildContext context) {
    if (_isLoadingShowing) return;
    _isLoadingShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    ).then((_) => _isLoadingShowing = false);
  }

  void _dismissLoadingDialog(BuildContext context) {
    if (_isLoadingShowing) {
      _isLoadingShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showPaymentFailedDialog(BuildContext context, int orderId, CheckoutCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'فشلت عملية الدفع',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
        ),
        content: const Text(
          'لم تكتمل عملية الدفع الإلكتروني بنجاح. هل ترغب في التحويل للدفع عند الاستلام لتأكيد الطلب؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              setState(() {
                _selectedPaymentMethod = _paymentMethods.firstWhere(
                  (m) => m.code == 'cod',
                  orElse: () => _paymentMethods.first,
                );
              });
              cubit.switchPaymentMethod(
                orderId,
                'cod',
              );
            },
            child: const Text('نعم، الدفع عند الاستلام'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              cubit.cancelOrder(orderId);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('إلغاء الطلب'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      final theme = Theme.of(context);
      final cs = theme.colorScheme;
      final s = S.of(context);

      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<CheckoutCubit>()
              ..fetchPaymentMethods()
              ..fetchCheckoutSummary(),
          ),
          BlocProvider(create: (_) => getIt<AddressCubit>()..loadAddresses()),
          BlocProvider(create: (_) => getIt<ProfileCubit>()..fetchProfile()),
        ],
        child: Builder(
          builder: (context) {
            return BlocListener<CheckoutCubit, CheckoutState>(
              listener: (context, state) {
                if (state is CheckoutLoading) {
                  _showLoadingDialog(context);
                } else if (state is CheckoutError) {
                  _dismissLoadingDialog(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else if (state is CheckoutSuccess) {
                  _dismissLoadingDialog(context);
                  final provider = _selectedPaymentMethod?.provider;
                  final isOnline = provider != null &&
                      provider.isNotEmpty &&
                      provider != 'manual' &&
                      _selectedPaymentMethod?.code != 'cod';
                  if (isOnline) {
                    final paymentRequest = PaymentRequest(
                      orderId: state.result.orderId,
                      orderNumber: state.result.orderNumber,
                      amount: state.result.total,
                      currency: 'SAR',
                      paymentMethodCode: _selectedPaymentMethod!.code,
                      publishableKey: state.result.publishableKey,
                      amountMinorUnits: state.result.amountMinorUnits,
                      paymentUrl: state.result.paymentUrl,
                    );

                    // Capture references before async gap (BuildContext safety).
                    final cubit = context.read<CheckoutCubit>();
                    final orderId = state.result.orderId;
                    final currentContext = context;
                    getIt<PaymentService>()
                        .processPayment(context, provider, paymentRequest)
                        .then((result) {
                          if (!mounted) return;
                          if (result.status == AppPaymentStatus.paid && result.paymentId != null) {
                            cubit.verifyPayment(orderId, result.paymentId!);
                          } else if (result.status == AppPaymentStatus.pending) {
                            // User is redirected to external payment gateway (web)
                          } else {
                            _showPaymentFailedDialog(currentContext, orderId, cubit);
                          }
                        });
                  } else {
                    context.pushReplacement(
                      Routes.orderSuccess,
                      extra: state.result,
                    );
                  }
                } else if (state is PaymentVerified) {
                  _dismissLoadingDialog(context);
                  context.pushReplacement(
                    Routes.orderSuccess,
                    extra: state.result,
                  );
                } else if (state is PaymentMethodSwitched) {
                  _dismissLoadingDialog(context);
                  context.pushReplacement(
                    Routes.orderSuccess,
                    extra: state.result,
                  );
                } else if (state is OrderCancelled) {
                  _dismissLoadingDialog(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else if (state is CheckoutInitial) {
                  _dismissLoadingDialog(context);
                } else if (state is PaymentMethodsLoaded) {
                  setState(() {
                    _paymentMethods = state.methods;
                    if (_paymentMethods.isNotEmpty) {
                      _selectedPaymentMethod = _paymentMethods.firstWhere(
                        (m) => m.code == 'cod',
                        orElse: () => _paymentMethods.first,
                      );
                    }
                  });
                } else if (state is PaymentMethodsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else if (state is CouponApplied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is CouponRemoved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Scaffold(
                backgroundColor: cs.surface,
                bottomNavigationBar: _buildOrderActionBar(s, theme, cs),
                appBar: AppBar(
                  backgroundColor: cs.surface,
                  elevation: 0,
                  title: Text(
                    s.checkout_title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
                    onPressed: () => context.pop(),
                  ),
                ),
                body: BlocBuilder<CheckoutCubit, CheckoutState>(
                  buildWhen: (previous, current) =>
                      current is CheckoutSummaryLoading ||
                      current is CheckoutSummaryLoaded,
                  builder: (context, state) {
                    if (state is CheckoutSummaryLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    int lineCount = widget.cart.lines.length;
                    if (state is CheckoutSummaryLoaded) {
                      lineCount =
                          state.summary.cartSummary['line_count'] ?? lineCount;
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // Top Banner for Cart Items
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'يوجد $lineCount منتجات في سلتك',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 1. Fulfillment Mode & Location Display
                        _buildFulfillmentCard(context, s, theme, cs),
                        const SizedBox(height: 16),

                        // 2. Shipping Address selection (if delivery) or Branch Selector (if pickup)
                        if (!_isPickup) ...[
                          _buildAddressSelectionSection(s, theme, cs),
                          const SizedBox(height: 16),
                        ] else ...[
                          _buildBranchSelectionSection(s, theme, cs),
                          const SizedBox(height: 16),
                        ],

                        // 3. Delivery Schedule Section

                        // 4. Payment Method Section (Hardcoded COD)
                        _buildPaymentMethodSection(s, theme, cs),
                        const SizedBox(height: 16),

                        // 4. Coupons Section
                        _buildCouponSection(context, s, theme, cs),
                        const SizedBox(height: 16),

                        // 5. Loyalty Points Section
                        _buildLoyaltyPointsSection(s, theme, cs),
                        const SizedBox(height: 16),

                        // 6. Additional Notes
                        _buildNotesSection(s, theme, cs),
                        const SizedBox(height: 16),

                        // 7. Order Summary
                        _buildOrderSummaryCard(context, s, theme, cs),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    } catch (e, stack) {
      debugPrint("CHECKOUT_SCREEN_CRASH_ERROR: $e");
      debugPrint(stack.toString());
      rethrow;
    }
  }

  Widget _buildFulfillmentCard(
    BuildContext context,
    S s,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الاستلام',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPickup = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: !_isPickup
                        ? AppColors.primary
                        : cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: !_isPickup
                          ? AppColors.primary
                          : cs.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'توصيل الطلبات للعنوان',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_isPickup ? Colors.white : cs.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '31.95 ر.س',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_isPickup
                              ? Colors.white70
                              : cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPickup = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isPickup
                        ? AppColors.primary
                        : cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isPickup
                          ? AppColors.primary
                          : cs.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'استلام من المتجر',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isPickup ? Colors.white : cs.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مجاناً',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isPickup
                              ? Colors.white70
                              : cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSelectionSection(S s, ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.shipping_address,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                context.push(Routes.addresses).then((_) {
                  _loadFulfillmentSettings();
                });
              },
              icon: const Icon(
                Icons.edit_location_alt_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                s.select_option,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return const SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            } else if (state is AddressLoaded) {
              final addresses = state.addresses;
              if (addresses.isEmpty) {
                return GestureDetector(
                  onTap: () {
                    context.push(Routes.addresses);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cs.outlineVariant.withOpacity(0.5),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_location_alt_rounded,
                          size: 32,
                          color: cs.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.addr_add_new_short,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Auto select default address or first one
              if (_selectedAddress == null) {
                final def = addresses.firstWhere(
                  (a) => a.isDefault,
                  orElse: () => addresses.first,
                );
                _selectedAddress = def;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAddress?.title ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress?.fullAddress ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AddressError) {
              return SizedBox(
                height: 80,
                child: Center(child: Text(state.message)),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBranchSelectionSection(S s, ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'اختر فرع الاستلام (المسلخ / الفرع)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_branches.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_branches.length} فروع',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_loadingBranches)
          const SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_branches.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.store_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'الفرع الرئيسي (الرياض - طريق الملك فهد)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: _branches.map((b) {
              final isSelected = _selectedBranch?.id == b.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBranch = b;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : cs.outlineVariant.withValues(alpha: 0.5),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : cs.onSurfaceVariant.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  b.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isSelected ? AppColors.primary : cs.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    b.city,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              b.address,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            if (b.openingHours != null && b.openingHours!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                '🕒 ${b.openingHours!}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(S s, ThemeData theme, ColorScheme cs) {
    if (_paymentMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.payment_method,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod?.id == method.id;
          IconData iconData;
          Color iconColor;
          String? brandLogoUrl;

          switch (method.code) {
            case 'cod':
              iconData = Icons.payments_rounded;
              iconColor = Colors.green;
              brandLogoUrl = null;
              break;
            case 'visa':
            case 'mastercard':
            case 'visa_mastercard':
              iconData = Icons.credit_card_rounded;
              iconColor = const Color(0xFF1A1F71);
              brandLogoUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/200px-Visa_Inc._logo.svg.png';
              break;
            case 'mada':
              iconData = Icons.account_balance_wallet_rounded;
              iconColor = const Color(0xFF004B87);
              brandLogoUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Mada_Logo.svg/200px-Mada_Logo.svg.png';
              break;
            case 'stc_pay':
              iconData = Icons.phone_android_rounded;
              iconColor = const Color(0xFF4F008C);
              brandLogoUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/STC_Pay_Logo.svg/200px-STC_Pay_Logo.svg.png';
              break;
            case 'apple_pay':
              iconData = Icons.phone_iphone_rounded;
              iconColor = Colors.black87;
              brandLogoUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Apple_Pay_logo.svg/200px-Apple_Pay_logo.svg.png';
              break;
            case 'tamara':
              iconData = Icons.calendar_month_rounded;
              iconColor = const Color(0xFF3DCBAB);
              brandLogoUrl = null;
              break;
            case 'tabby':
              iconData = Icons.calendar_month_rounded;
              iconColor = const Color(0xFF3BFFC1);
              brandLogoUrl = null;
              break;
            default:
              iconData = Icons.payment_rounded;
              iconColor = AppColors.primary;
              brandLogoUrl = null;
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPaymentMethod = method;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : cs.outlineVariant.withValues(alpha: 0.4),
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  // Radio indicator
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : cs.onSurfaceVariant.withValues(alpha: 0.35),
                        width: 2,
                      ),
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // Name & description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? cs.onSurface : cs.onSurface,
                          ),
                        ),
                        if (method.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            method.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Brand icon/logo
                  Container(
                    width: 42,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: brandLogoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              brandLogoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  Icon(iconData, color: iconColor, size: 18),
                            ),
                          )
                        : Icon(iconData, color: iconColor, size: 18),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCouponSection(
    BuildContext context,
    S s,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.coupon_code,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: s.coupon_hint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                final code = _couponController.text.trim();
                if (code.isNotEmpty) {
                  context.read<CheckoutCubit>().applyCoupon(code);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.coupon_hint),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                minimumSize: const Size(0, 50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                s.apply,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoyaltyPointsSection(S s, ThemeData theme, ColorScheme cs) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final points = state.profile.loyaltyPoints;
          if (points <= 0) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.redeem_points,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.available_points(points),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _redeemPoints,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _redeemPoints = val;
                    });
                  },
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNotesSection(S s, ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.notes_label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: s.notes_hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant.withOpacity(0.5),
              ),
              filled: true,
              fillColor: cs.surfaceContainerLowest,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withOpacity(0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard(
    BuildContext context,
    S s,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen: (previous, current) =>
          current is CheckoutSummaryLoaded || current is CheckoutSummaryLoading,
      builder: (context, state) {
        double subtotal = widget.cart.subtotal;
        double tax = (widget.cart.total - widget.cart.subtotal).clamp(
          0.0,
          double.infinity,
        );
        double discount = 0.0;
        double shipping = _isPickup ? 0.0 : 31.95; // Default fallback
        double total = widget.cart.total;

        if (state is CheckoutSummaryLoaded) {
          subtotal = (state.summary.orderSummary['subtotal'] ?? subtotal)
              .toDouble();
          discount = (state.summary.orderSummary['discount'] ?? discount)
              .toDouble();
          shipping = _isPickup
              ? 0.0
              : (state.summary.orderSummary['shipping_cost'] ?? shipping)
                    .toDouble();
          total = subtotal - discount + shipping + tax;
        } else {
          total = subtotal - discount + shipping + tax;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.order_summary,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                s.subtotal,
                '${subtotal.toStringAsFixed(2)} ${s.sar}',
                theme,
                cs,
              ),
              if (!_isPickup) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'رسوم التوصيل',
                  '${shipping.toStringAsFixed(2)} ${s.sar}',
                  theme,
                  cs,
                ),
              ],
              if (discount > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'الخصم',
                  '-${discount.toStringAsFixed(2)} ${s.sar}',
                  theme,
                  cs,
                ),
              ],
              if (tax > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  s.tax,
                  '${tax.toStringAsFixed(2)} ${s.sar}',
                  theme,
                  cs,
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.order_total,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} ${s.sar}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderActionBar(S s, ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () => _confirmAndPlaceOrder(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              s.confirm_order,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
