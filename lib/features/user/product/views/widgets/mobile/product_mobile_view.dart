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
import '../../../../favorites/presentation/manager/favorites_cubit.dart';
import '../../../../favorites/presentation/manager/favorites_state.dart';
import '../product_details_widgets.dart';

class ProductMobileView extends StatefulWidget {
  final Product product;
  final String? initialPortion;
  const ProductMobileView({
    super.key,
    required this.product,
    this.initialPortion,
  });

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
  late String _currentPortion;

  @override
  void initState() {
    super.initState();
    _currentPortion = widget.initialPortion ?? 'full';
    _initSelectedSize();
  }

  @override
  void didUpdateWidget(covariant ProductMobileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPortion != null && widget.initialPortion != oldWidget.initialPortion) {
      _currentPortion = widget.initialPortion!;
      _initSelectedSize();
    } else if (_selectedSize == null) {
      _initSelectedSize();
    }
  }

  double get _portionFactor =>
      _currentPortion == 'half' ? 0.5 : _currentPortion == 'quarter' ? 0.25 : 1.0;

  List<ProductSize> get _filteredSizes {
    if (!widget.product.hasSizes || widget.product.sizes.isEmpty) return const [];
    final portionSizes = widget.product.sizes
        .where((s) => (s.portionType ?? 'full') == _currentPortion)
        .toList();
    if (portionSizes.isNotEmpty) return portionSizes;
    return widget.product.sizes;
  }

  void _initSelectedSize() {
    final available = _filteredSizes;
    if (available.isNotEmpty) {
      _selectedSize = available.firstWhere(
        (s) => s.isDefault,
        orElse: () => available.first,
      );
    } else {
      _selectedSize = null;
    }
  }

  void _onSelectPortion(String portionType) {
    if (_currentPortion == portionType) return;
    setState(() {
      _currentPortion = portionType;
      _initSelectedSize();
    });
  }

  double get _currentPrice =>
      _selectedSize != null ? _selectedSize!.price : (widget.product.displayPrice * _portionFactor).roundToDouble();

  double get _cuttingExtra => _selectedCuttingOption?.extraPrice ?? 0.0;

  double get _packagingExtra => widget.product.packagingOptions
      .where((p) => _selectedPackagingIds.contains(p.id))
      .fold<double>(0.0, (sum, p) => sum + (p.extraPrice ?? 0.0));

  double get _unitPriceWithOptions => _currentPrice + _cuttingExtra + _packagingExtra;

  int get _currentCalories =>
      _selectedSize != null ? _selectedSize!.calories : ((widget.product.calories * _portionFactor).round());

  int get _currentLoyaltyPoints => _selectedSize != null
      ? _selectedSize!.loyaltyPoints
      : (((widget.product.loyaltyPoints ?? 0) * _portionFactor).round());

  int get _currentPointsPrice => _selectedSize != null
      ? _selectedSize!.pointsPrice
      : ((_currentPrice * 4).round());

  String get _currentWeightRange {
    if (_selectedSize != null) {
      return _selectedSize!.effectiveWeightRange;
    }
    if (widget.product.weightKg != null && widget.product.weightKg! > 0) {
      final w = widget.product.weightKg!;
      return '${w.toStringAsFixed(w % 1 == 0 ? 0 : 1)} كجم تقريباً';
    }
    return widget.product.subtitle.isNotEmpty
        ? widget.product.subtitle
        : 'حسب الاختيار';
  }

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

  Widget _buildPortionTabs(ColorScheme cs, bool isDark, bool isAr) {
    final portions = widget.product.effectivePortions;
    if (portions.isEmpty) return const SizedBox.shrink();

    String getPortionTitle(ProductPortion p) {
      if (p.type == 'full') return isAr ? 'كامل' : 'Whole';
      if (p.type == 'half') return isAr ? 'نصف' : 'Half';
      if (p.type == 'quarter') return isAr ? 'ربع' : 'Quarter';
      return p.name;
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.5 : 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? cs.outlineVariant.withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: portions.map((p) {
          final isSelected = _currentPortion == p.type;
          final portionTitle = getPortionTitle(p);
          final activeColor = isDark ? cs.primary : const Color(0xFF9B1B30);

          return Expanded(
            child: GestureDetector(
              onTap: () => _onSelectPortion(p.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      portionTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? (isDark ? cs.onPrimary : Colors.white)
                            : cs.onSurface,
                      ),
                    ),
                    if (p.startingPrice > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        isAr
                            ? 'من ${p.startingPrice.toStringAsFixed(0)} ر.س'
                            : 'From ${p.startingPrice.toStringAsFixed(0)} SAR',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? cs.onPrimary : Colors.white).withValues(alpha: 0.9)
                              : activeColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _imagePlaceholder(ColorScheme cs, bool isDark) => Container(
        color: isDark ? cs.surfaceContainerHighest : const Color(0xFFFBF6EF),
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

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
            actions: [
              Builder(
                builder: (context) {
                  bool isFav = false;
                  try {
                    final favState = context.watch<FavoritesCubit>().state;
                    if (favState is FavoritesLoaded) {
                      isFav = favState.favoriteIds.contains(product.id);
                    }
                  } catch (_) {}

                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.redAccent : cs.onSurface,
                          size: 22,
                        ),
                      ),
                      onPressed: () {
                        context.read<FavoritesCubit>().toggleFavorite(product: product);
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(cs, isDark),
                        )
                      : _imagePlaceholder(cs, isDark),
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
                  CarcassWeightCard(weight: _currentWeightRange),
                  const SizedBox(height: 12),
                  if (_currentCalories > 0) ...[
                    CaloriesBadgeBar(calories: _currentCalories),
                    const SizedBox(height: 10),
                  ],
                  if (_currentLoyaltyPoints > 0) ...[
                    LoyaltyRewardBar(points: _currentLoyaltyPoints),
                    const SizedBox(height: 18),
                  ],
                  if (product.isCarcass || product.effectivePortions.isNotEmpty) ...[
                    SectionHeader(title: isAr ? 'تقسيم الذبيحة' : 'Carcass Portion'),
                    const SizedBox(height: 10),
                    _buildPortionTabs(cs, isDark, isAr),
                    const SizedBox(height: 16),
                  ],
                  const SectionHeader(title: 'الحجم'),
                  const SizedBox(height: 10),
                  CarcassSizesSelector(
                    sizes: _filteredSizes,
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
                  selectedSize: _selectedSize,
                  unitBasePrice: _currentPrice,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quantity Stepper and Total Price matching reference design
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        (_unitPriceWithOptions * _quantity).toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const SaudiRiyalIcon(size: 16),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() => _quantity -= 1);
                            }
                          },
                          icon: const Icon(Icons.remove, size: 18),
                          visualDensity: VisualDensity.compact,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            _quantity.toInt().toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _quantity += 1);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Full-width Add to Cart Button
              BlocBuilder<CartCubit, CartState>(
                builder: (ctx, cartState) {
                  final isAdding = cartState is CartItemAdding;
                  return ElevatedButton(
                    onPressed: isAdding || !product.isAvailable
                        ? null
                        : () => _addToCart(ctx, product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isAdding
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                !product.isAvailable ? s.out_of_stock : s.add_to_cart,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
