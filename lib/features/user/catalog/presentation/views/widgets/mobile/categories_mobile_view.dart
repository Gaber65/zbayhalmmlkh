import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_state.dart';
import 'package:dhabayih_lmamlaka/features/user/address/domain/services/fulfillment_service.dart';
import 'package:dhabayih_lmamlaka/features/user/address/presentation/manager/address_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/address/presentation/views/widgets/address_selection_bottom_sheet.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/category.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/presentation/manager/catalog_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/presentation/manager/catalog_state.dart';
import 'package:dhabayih_lmamlaka/features/user/favorites/presentation/manager/favorites_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/favorites/presentation/manager/favorites_state.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/manager/home_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/manager/home_state.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_categories_and_products.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_design.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_header_and_banner.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_sheets.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/user_notifications_sheet.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Mobile Categories & Browse view matching `<section class="view" id="browseView">`
/// in `design_reference/index.html`, with full Arabic/English & Light/Dark mode support.
class CategoriesMobileView extends StatefulWidget {
  const CategoriesMobileView({super.key});

  @override
  State<CategoriesMobileView> createState() => _CategoriesMobileViewState();
}

class _CategoriesMobileViewState extends State<CategoriesMobileView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Category? _selectedCategory;
  String _sortBy = 'default';
  String? _selectedLocationOverride;
  String _fulfillmentMode = 'delivery';
  final Map<int, List<Product>> _categoryProductsCache = {};
  bool _loadingCategoryProducts = false;

  @override
  void initState() {
    super.initState();
    _loadSavedFulfillment();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedFulfillment() async {
    try {
      final mode = await FulfillmentService.getFulfillmentMode();
      final locationText = await FulfillmentService.getDisplayLocation();
      if (mounted) {
        setState(() {
          _fulfillmentMode = mode;
          if (locationText != null && locationText.isNotEmpty) {
            _selectedLocationOverride = locationText;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _openAddressSelectionBottomSheet(BuildContext context) async {
    if (!getIt.isRegistered<AddressCubit>()) return;
    final result = await AddressSelectionBottomSheet.show(
      context,
      initialLocation: _selectedLocationOverride,
      initialMode: _fulfillmentMode,
      cubit: getIt<AddressCubit>()..loadAddresses(),
    );

    if (result != null && mounted) {
      final resMode = result['mode'] as String?;
      final text = result['displayText'] as String?;
      setState(() {
        if (resMode != null) _fulfillmentMode = resMode;
        if (text != null && text.isNotEmpty) {
          _selectedLocationOverride = text;
        }
      });
    }
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

  String? _resolveDeliveryLocation(BuildContext context) {
    if (_selectedLocationOverride != null &&
        _selectedLocationOverride!.isNotEmpty) {
      return _selectedLocationOverride;
    }
    try {
      final homeState = context.watch<HomeCubit>().state;
      if (homeState is HomeLoaded) {
        return homeState.homeData.deliveryLocation;
      }
    } catch (_) {}
    return null;
  }

  List<Category> _resolveCategories(BuildContext context, CatalogState state) {
    if (state is CatalogLoaded && state.categories.isNotEmpty) {
      return state.categories;
    }
    if (state is CategoriesLoaded && state.categories.isNotEmpty) {
      return state.categories;
    }
    try {
      final homeState = context.read<HomeCubit>().state;
      if (homeState is HomeLoaded && homeState.homeData.categories.isNotEmpty) {
        return homeState.homeData.categories;
      }
    } catch (_) {}
    return const [];
  }

  List<Product> _resolveAllProducts(BuildContext context, CatalogState state) {
    final map = <int, Product>{};
    if (state is CatalogLoaded) {
      for (final p in state.products) {
        map[p.id] = p;
      }
      for (final p in state.bestSellers) {
        map.putIfAbsent(p.id, () => p);
      }
    } else if (state is ProductsByCategoryLoaded) {
      for (final p in state.products) {
        map[p.id] = p;
      }
    }

    try {
      final homeState = context.read<HomeCubit>().state;
      if (homeState is HomeLoaded) {
        for (final p in homeState.homeData.featuredProducts) {
          map.putIfAbsent(p.id, () => p);
        }
        for (final p in homeState.homeData.bestSellers) {
          map.putIfAbsent(p.id, () => p);
        }
        for (final p in homeState.homeData.recommendedProducts) {
          map.putIfAbsent(p.id, () => p);
        }
      }
    } catch (_) {}

    for (final list in _categoryProductsCache.values) {
      for (final p in list) {
        map.putIfAbsent(p.id, () => p);
      }
    }

    return map.values.toList();
  }

  Future<void> _selectCategory(BuildContext context, Category? category) async {
    setState(() {
      _selectedCategory = category;
    });
    if (category == null) return;
    if (_categoryProductsCache.containsKey(category.id)) return;

    try {
      final cubit = context.read<CatalogCubit>();
      setState(() => _loadingCategoryProducts = true);
      final res = await cubit.repository.getProductsByCategory(category.id);
      if (!mounted) return;
      res.fold(
        (_) => setState(() => _loadingCategoryProducts = false),
        (products) {
          setState(() {
            _categoryProductsCache[category.id] = products;
            _loadingCategoryProducts = false;
          });
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _loadingCategoryProducts = false);
      }
    }
  }

  List<Product> _filterAndSortProducts(
    BuildContext context,
    List<Product> allProducts,
  ) {
    final selectedCat = _selectedCategory;
    final query = _searchQuery.trim().toLowerCase();

    Iterable<Product> list = allProducts;

    if (selectedCat != null) {
      final cachedForCat = _categoryProductsCache[selectedCat.id];
      if (cachedForCat != null && cachedForCat.isNotEmpty) {
        list = cachedForCat;
      } else {
        list = list.where((p) {
          if (p.categoryId != null && p.categoryId == selectedCat.id) {
            return true;
          }
          final catName = selectedCat.name.trim();
          if (catName.isNotEmpty &&
              (p.categoryName?.contains(catName) == true ||
                  p.localizedCategoryTag(context).contains(catName) ||
                  p.title.contains(catName))) {
            return true;
          }
          return false;
        });
      }
    }

    if (query.isNotEmpty) {
      list = list.where((p) {
        final hay = [
          p.title,
          p.localizedTitle(context),
          p.subtitle,
          p.categoryName ?? '',
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

  void _onProductDetailTap(BuildContext context, Product product) {
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
        onOpenFullDetails: () => _onProductDetailTap(context, product),
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

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final favCount = _resolveFavoritesCount(context);
    final deliveryLoc = _resolveDeliveryLocation(context);

    return Scaffold(
      backgroundColor: p.paper,
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          final categories = _resolveCategories(context, state);
          final allProducts = _resolveAllProducts(context, state);
          final filteredProducts = _filterAndSortProducts(context, allProducts);

          final String viewTitle = _searchQuery.isNotEmpty
              ? kTr(
                  context,
                  'بحث: $_searchQuery',
                  'Search: $_searchQuery',
                )
              : (_selectedCategory != null
                  ? _selectedCategory!.name
                  : kTr(context, 'التصنيفات', 'Categories'));

          final int subtitleCount = filteredProducts.isNotEmpty
              ? filteredProducts.length
              : categories.length;
          final String viewSubtitle = filteredProducts.isNotEmpty
              ? kTr(
                  context,
                  '$subtitleCount منتج مختار بعناية',
                  '$subtitleCount carefully selected products',
                )
              : kTr(
                  context,
                  '${categories.length} أقسام رئيسية مختارة بعناية',
                  '${categories.length} carefully curated categories',
                );

          return Column(
            children: [
              KingdomHeaderWidget(
                deliveryLocation: deliveryLoc,
                favoritesCount: favCount,
                searchController: _searchController,
                onSearchChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                onLocationTap: () => _openAddressSelectionBottomSheet(context),
                onFavoritesTap: () => context.push(Routes.favorites),
                onNotificationsTap: () => UserNotificationsSheet.show(context),
                onFilterTap: () {
                  showKingdomFilterSheet(
                    context,
                    initialSort: _sortBy,
                    initialCategory: _selectedCategory,
                    categories: categories,
                    onApplySort: (sort) {
                      setState(() => _sortBy = sort);
                    },
                    onApplyCategory: (cat) {
                      _selectCategory(context, cat);
                    },
                  );
                },
              ),
              Expanded(
                child: _buildBodyContent(
                  context,
                  state: state,
                  palette: p,
                  categories: categories,
                  filteredProducts: filteredProducts,
                  viewTitle: viewTitle,
                  viewSubtitle: viewSubtitle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context, {
    required CatalogState state,
    required KPalette palette,
    required List<Category> categories,
    required List<Product> filteredProducts,
    required String viewTitle,
    required String viewSubtitle,
  }) {
    if ((state is CatalogLoading || state is CatalogInitial) &&
        categories.isEmpty &&
        filteredProducts.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: palette.red),
      );
    }

    if (state is CatalogError &&
        categories.isEmpty &&
        filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: palette.red,
              ),
              const SizedBox(height: 12),
              Text(
                state.message,
                style: kText(14, weight: FontWeight.w600, color: palette.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<CatalogCubit>().fetchCatalog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(S.of(context).retry_button),
              ),
            ],
          ),
        ),
      );
    }

    final bool showCategoryGrid =
        _selectedCategory == null && _searchQuery.trim().isEmpty;

    return RefreshIndicator(
      color: palette.red,
      onRefresh: () => context.read<CatalogCubit>().fetchCatalog(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // .view-head
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          viewTitle,
                          style: kText(
                            23,
                            weight: FontWeight.w700,
                            color: palette.ink,
                            letterSpacing: -0.02 * 23,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (_selectedCategory != null)
                        KTap(
                          onTap: () {
                            context.push(
                              Routes.productsByCategory,
                              extra: _selectedCategory,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  kTr(
                                    context,
                                    'صفحة القسم',
                                    'Category Page',
                                  ),
                                  style: kText(
                                    12,
                                    weight: FontWeight.w600,
                                    color: palette.red,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Transform.flip(
                                  flipX: !kIsAr(context),
                                  child: KSvgIcon(
                                    KIcon.chevron,
                                    size: 15,
                                    color: palette.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewSubtitle,
                    style: kText(
                      12,
                      color: palette.inkMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // .browse-bar (#browseFilters)
            if (categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    KingdomFilterChip(
                      label: kTr(context, 'الكل', 'All'),
                      selected: _selectedCategory == null,
                      onTap: () => _selectCategory(context, null),
                    ),
                    ...categories.map(
                      (cat) => KingdomFilterChip(
                        label: cat.name,
                        selected: _selectedCategory?.id == cat.id,
                        onTap: () => _selectCategory(context, cat),
                      ),
                    ),
                  ],
                ),
              ),

            // #categoryBrowseGrid (2-column photographic category cards)
            if (showCategoryGrid && categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                child: KingdomCategoryBrowseGrid(
                  categories: categories,
                  onCategoryTap: (category) {
                    context.push(Routes.productsByCategory, extra: category);
                  },
                ),
              ),

            if (_loadingCategoryProducts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: palette.red),
                ),
              ),

            // #browseProducts (2-column product grid)
            if (filteredProducts.isNotEmpty)
              KingdomProductGrid(
                products: filteredProducts,
                onProductTap: (prod) => _onProductDetailTap(context, prod),
                onProductCtaTap: (prod) => _onProductCtaTap(context, prod),
              )
            else if (!_loadingCategoryProducts &&
                (!showCategoryGrid || categories.isEmpty))
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.line),
                  ),
                  child: Column(
                    children: [
                      Text(
                        kTr(
                          context,
                          'لا توجد منتجات مطابقة',
                          'No matching products',
                        ),
                        textAlign: TextAlign.center,
                        style: kText(
                          15,
                          weight: FontWeight.w700,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kTr(
                          context,
                          'جرّب تغيير البحث أو اختيار قسم آخر.',
                          'Try changing your search or selecting another category.',
                        ),
                        textAlign: TextAlign.center,
                        style: kText(
                          12,
                          color: palette.inkMuted,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom secondary action button (#backHomeBtn)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: KTap(
                onTap: () {
                  if (_selectedCategory != null || _searchQuery.isNotEmpty) {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategory = null;
                    });
                  } else {
                    context.go(Routes.home);
                  }
                },
                radius: BorderRadius.circular(13),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 46),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: palette.line),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (_selectedCategory != null || _searchQuery.isNotEmpty)
                        ? kTr(context, 'عرض كل الأقسام', 'Show All Categories')
                        : kTr(context, 'العودة للرئيسية', 'Back to Home'),
                    style: kText(
                      13,
                      weight: FontWeight.w600,
                      color: palette.inkSoft,
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
}
