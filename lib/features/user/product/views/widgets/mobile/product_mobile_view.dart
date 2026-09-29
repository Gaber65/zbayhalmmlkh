import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_state.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_state.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/widgets/price_widget.dart';
import '../product_details_widgets.dart';

class ProductMobileView extends StatefulWidget {
  final Product product;
  const ProductMobileView({super.key, required this.product});

  @override
  State<ProductMobileView> createState() => _ProductMobileViewState();
}

class _ProductMobileViewState extends State<ProductMobileView> {
  ProductOption? _selectedCuttingOption;
  ProductSize? _selectedSize;
  final Set<int> _selectedPackagingIds = {};
  final Set<int> _selectedExcludedPartIds = {};
  double _quantity = 1.0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSelectedSize();
  }

  @override
  void didUpdateWidget(covariant ProductMobileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedSize == null) {
      _initSelectedSize();
    }
  }

  void _initSelectedSize() {
    if (widget.product.hasSizes && widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.firstWhere(
        (s) => s.isDefault,
        orElse: () => widget.product.sizes.first,
      );
    }
  }

  double get _currentPrice =>
      _selectedSize != null ? _selectedSize!.price : widget.product.displayPrice;

  int get _currentCalories =>
      _selectedSize != null ? _selectedSize!.calories : widget.product.calories;

  int get _currentLoyaltyPoints => _selectedSize != null
      ? _selectedSize!.loyaltyPoints
      : (widget.product.loyaltyPoints ?? 0);

  int get _currentPointsPrice => _selectedSize != null
      ? _selectedSize!.pointsPrice
      : ((_currentPrice * 4).round());

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showLoginRequiredSheet(BuildContext ctx) {
    final s = S.of(ctx);
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final isAr = Localizations.localeOf(ctx).languageCode == 'ar';

    showModalBottomSheet(
      context: ctx,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bCtx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAr ? 'تسجيل الدخول مطلوب' : 'Login Required',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? 'يرجى تسجيل الدخول أو إنشاء حساب لإضافة المنتجات إلى السلة ومتابعة الطلب'
                  : 'Please log in or create an account to add items to the cart and proceed with your order',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(bCtx).pop();
                ctx.push(Routes.login);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                s.login_register,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(bCtx).pop(),
              child: Text(
                isAr ? 'إلغاء' : 'Cancel',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext ctx, Product product) {
    final authState = ctx.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      _showLoginRequiredSheet(ctx);
      return;
    }

    ctx.read<CartCubit>().addToCart(
          productId: product.id,
          quantity: _quantity,
          sizeId: _selectedSize?.id,
          cuttingOptionId: _selectedCuttingOption?.id,
          packagingIds: _selectedPackagingIds.toList(),
          excludedPartIds: _selectedExcludedPartIds.toList(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
  }

  Widget _imagePlaceholder(ColorScheme cs) => Container(
        color: cs.surfaceContainerHighest,
        child: Icon(Icons.image_not_supported_outlined,
            size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
      );

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';

    final displayTitle =
        isAr ? (product.titleAr ?? product.title) : (product.titleEn ?? product.title);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: cs.surface,
            leading: IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.arrow_back_rounded, color: cs.onSurface, size: 22),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(cs),
                        )
                      : _imagePlaceholder(cs),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            cs.surface.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StockBadge(isAvailable: product.isAvailable),
                  ],
                ),
                const SizedBox(height: 6),
                if (product.subtitle.isNotEmpty) ...[
                  Text(
                    product.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (product.description != null && product.description!.isNotEmpty) ...[
                  Text(
                    product.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (product.hasSizes && product.sizes.isNotEmpty) ...[
                  CarcassPriceCards(
                    price: _currentPrice,
                    pointsPrice: _currentPointsPrice,
                  ),
                  const SizedBox(height: 12),
                  if (_currentCalories > 0) ...[
                    CaloriesBadgeBar(calories: _currentCalories),
                    const SizedBox(height: 10),
                  ],
                  if (_currentLoyaltyPoints > 0) ...[
                    LoyaltyRewardBar(points: _currentLoyaltyPoints),
                    const SizedBox(height: 18),
                  ],
                  const SectionHeader(title: 'الحجم'),
                  const SizedBox(height: 10),
                  CarcassSizesSelector(
                    sizes: product.sizes,
                    selected: _selectedSize,
                    onSelect: (size) => setState(() => _selectedSize = size),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  PriceSection(product: product),
                  const SizedBox(height: 20),
                  if (product.loyaltyPoints != null && product.loyaltyPoints! > 0) ...[
                    LoyaltyBadge(points: product.loyaltyPoints!),
                    const SizedBox(height: 16),
                  ],
                ],
                SectionHeader(title: s.quantity_label),
                QuantitySelector(
                  quantity: _quantity,
                  onChanged: (v) => setState(() => _quantity = v),
                ),
                const SizedBox(height: 20),
                if (product.cuttingOptions.isNotEmpty) ...[
                  SectionHeader(title: s.cutting_options),
                  const SizedBox(height: 8),
                  CuttingOptionsSelector(
                    options: product.cuttingOptions,
                    selected: _selectedCuttingOption,
                    onSelect: (opt) => setState(() => _selectedCuttingOption = opt),
                  ),
                  const SizedBox(height: 20),
                ],
                if (product.packagingOptions.isNotEmpty) ...[
                  SectionHeader(title: s.packaging_options),
                  const SizedBox(height: 8),
                  PackagingOptionsSelector(
                    options: product.packagingOptions,
                    selectedIds: _selectedPackagingIds,
                    onToggle: (id) => setState(() {
                      if (_selectedPackagingIds.contains(id)) {
                        _selectedPackagingIds.remove(id);
                      } else {
                        _selectedPackagingIds.add(id);
                      }
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
                if (product.excludedParts.isNotEmpty) ...[
                  SectionHeader(title: s.excluded_parts),
                  const SizedBox(height: 8),
                  ExcludedPartsSelector(
                    parts: product.excludedParts,
                    selectedIds: _selectedExcludedPartIds,
                    onToggle: (id) => setState(() {
                      if (_selectedExcludedPartIds.contains(id)) {
                        _selectedExcludedPartIds.remove(id);
                      } else {
                        _selectedExcludedPartIds.add(id);
                      }
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
                SectionHeader(
                  title: s.notes_label,
                  trailing: Text(
                    s.optional_field,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  maxLength: 250,
                  decoration: InputDecoration(
                    hintText: s.notes_hint,
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                SelectionSummary(
                  product: product,
                  selectedCuttingOption: _selectedCuttingOption,
                  selectedPackagingIds: _selectedPackagingIds,
                  selectedExcludedPartIds: _selectedExcludedPartIds,
                  quantity: _quantity,
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (ctx, cartState) {
          final isAdding = cartState is CartItemAdding;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ElevatedButton(
                onPressed: isAdding || !product.isAvailable
                    ? null
                    : () => _addToCart(ctx, product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isAdding
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 20),
                          const SizedBox(width: 8),
                          if (!product.isAvailable)
                            Text(
                              s.out_of_stock,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            )
                          else ...[
                            Text(
                              '${s.add_to_cart}  •  ${(_currentPrice * _quantity).toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            const SaudiRiyalIcon(size: 15, color: Colors.white),
                          ],
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
