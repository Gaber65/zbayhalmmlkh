import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_state.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/category.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/presentation/manager/catalog_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/presentation/manager/catalog_state.dart';
import 'package:dhabayih_lmamlaka/features/user/favorites/presentation/manager/favorites_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/favorites/presentation/manager/favorites_state.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_categories_and_products.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_design.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_header_and_banner.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_sheets.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/user_notifications_sheet.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductsByCategoryMobileView extends StatefulWidget {
  final Category category;

  const ProductsByCategoryMobileView({super.key, required this.category});

  @override
  State<ProductsByCategoryMobileView> createState() =>
      _ProductsByCategoryMobileViewState();
}

class _ProductsByCategoryMobileViewState
    extends State<ProductsByCategoryMobileView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'default';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _resolveFavoritesCount(BuildContext context) {
    try {
      final favState = context.watch<FavoritesCubit>().state;
      if (favState is FavoritesLoaded) {
        return favState.favoriteIds.length;
      }
    } catch (_) {}
    return 0;
  }

  CartCubit? _resolveCartCubit(BuildContext context) {
    try {
      return context.read<CartCubit>();
    } catch (_) {
      if (getIt.isRegistered<CartCubit>()) {
        return getIt<CartCubit>();
      }
      return null;
    }
  }

  void _showKingdomToast(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: kText(12, color: Colors.white, height: 1.4),
        ),
        backgroundColor: const Color(0xFF303B2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(milliseconds: 2300),
      ),
    );
  }

  void _onProductTap(BuildContext context, Product product) {
    if (product.isCarcass || product.effectivePortions.isNotEmpty) {
      context.push(Routes.carcassPortions, extra: product);
    } else {
      context.push(Routes.productDetails, extra: product);
    }
  }

  void _onProductCtaTap(BuildContext context, Product product) {
    if (!product.isEffectivelyAvailable) return;

    if (product.hasConfigurableOptions) {
      KingdomProductOptionsSheet.show(
        context: context,
        product: product,
        onConfirmAdd: ({
          required double quantity,
          int? sizeId,
          int? cuttingOptionId,
          List<int>? packagingIds,
          List<int>? excludedPartIds,
        }) {
          _performAddToCart(
            context,
            product: product,
            quantity: quantity,
            sizeId: sizeId,
            cuttingOptionId: cuttingOptionId,
            packagingIds: packagingIds,
            excludedPartIds: excludedPartIds,
          );
        },
        onOpenFullDetails: () => _onProductTap(context, product),
      );
      return;
    }

    _performAddToCart(context, product: product, quantity: 1);
  }

  void _performAddToCart(
    BuildContext context, {
    required Product product,
    required double quantity,
    int? sizeId,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
  }) {
    bool isAuthenticated = false;
    try {
      isAuthenticated = context.read<AuthCubit>().state is AuthAuthenticated;
    } catch (_) {}

    final cartCubit = _resolveCartCubit(context);
    if (isAuthenticated && cartCubit != null) {
      cartCubit.addToCart(
        productId: product.id,
        quantity: quantity,
        sizeId: sizeId,
        cuttingOptionId: cuttingOptionId,
        packagingIds: packagingIds,
        excludedPartIds: excludedPartIds,
      );
    }
    _showKingdomToast(
      context,
      kTr(context, 'تمت الإضافة إلى سلتك', 'Added to your cart'),
    );
  }

  List<Product> _filterAndSort(BuildContext context, List<Product> raw) {
    final query = _searchQuery.trim().toLowerCase();
    Iterable<Product> list = raw;
    if (query.isNotEmpty) {
      list = list.where((p) {
        final hay = [
          p.title,
          p.localizedTitle(context),
          p.subtitle,
          p.localizedCategoryTag(context),
        ].join(' ').toLowerCase();
        return hay.contains(query);
      });
    }
    final result = list.toList();
    switch (_sortBy) {
      case 'low':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'high':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final favCount = _resolveFavoritesCount(context);

    return Scaffold(
      backgroundColor: p.paper,
      body: Column(
        children: [
          KingdomHeaderWidget(
            deliveryLocation: null,
            favoritesCount: favCount,
            searchController: _searchController,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onBackTap: () => context.pop(),
            onLocationTap: () {},
            onFavoritesTap: () => context.push(Routes.favorites),
            onNotificationsTap: () => UserNotificationsSheet.show(context),
            onFilterTap: () {
              showKingdomFilterSheet(
                context,
                categories: const [],
                initialSort: _sortBy,
                onApplyCategory: (_) {},
                onApplySort: (sort) => setState(() => _sortBy = sort),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, state) {
                if (state is ProductsByCategoryLoading ||
                    state is CatalogInitial) {
                  return Center(
                    child: CircularProgressIndicator(color: p.red),
                  );
                } else if (state is CatalogError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: p.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: kText(
                              14,
                              weight: FontWeight.w600,
                              color: p.ink,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<CatalogCubit>()
                                .fetchProductsByCategory(widget.category.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: p.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(S.of(context).retry_button),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is ProductsByCategoryLoaded ||
                    state is CatalogLoaded) {
                  final rawProducts = state is ProductsByCategoryLoaded
                      ? state.products
                      : (state as CatalogLoaded).products;
                  final products = _filterAndSort(context, rawProducts);

                  return RefreshIndicator(
                    color: p.red,
                    onRefresh: () => context
                        .read<CatalogCubit>()
                        .fetchProductsByCategory(widget.category.id),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.category.name,
                                  style: kText(
                                    23,
                                    weight: FontWeight.w700,
                                    color: p.ink,
                                    letterSpacing: -0.02 * 23,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  kTr(
                                    context,
                                    '${products.length} منتج مختار بعناية',
                                    '${products.length} carefully selected products',
                                  ),
                                  style: kText(
                                    12,
                                    color: p.inkMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (products.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 28,
                                ),
                                decoration: BoxDecoration(
                                  color: p.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: p.line),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      S.of(context).no_products_in_category,
                                      textAlign: TextAlign.center,
                                      style: kText(
                                        15,
                                        weight: FontWeight.w700,
                                        color: p.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            KingdomProductGrid(
                              products: products,
                              onProductTap: (prod) =>
                                  _onProductTap(context, prod),
                              onProductCtaTap: (prod) =>
                                  _onProductCtaTap(context, prod),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                            child: KTap(
                              onTap: () => context.pop(),
                              radius: BorderRadius.circular(13),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 46),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: p.surface,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: p.line),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  kTr(context, 'العودة', 'Back'),
                                  style: kText(
                                    13,
                                    weight: FontWeight.w600,
                                    color: p.inkSoft,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
