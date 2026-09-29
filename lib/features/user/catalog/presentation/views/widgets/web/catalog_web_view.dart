import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/widgets/product_card.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../../../domain/entities/category.dart';
import '../../../manager/catalog_cubit.dart';
import '../../../manager/catalog_state.dart';
import '../../../../../cart/presentation/manager/cart_cubit.dart';
import 'filters/web_filters_sidebar.dart';
import 'filters/grid_control_header.dart';

class CatalogWebView extends StatefulWidget {
  final Category? initialCategory;

  const CatalogWebView({super.key, this.initialCategory});

  @override
  State<CatalogWebView> createState() => _CatalogWebViewState();
}

class _CatalogWebViewState extends State<CatalogWebView> {
  late CatalogCubit _categoriesCubit;
  late CatalogCubit _productsCubit;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _categoriesCubit = getIt<CatalogCubit>();
    _productsCubit = getIt<CatalogCubit>();

    _selectedCategory = widget.initialCategory;

    _categoriesCubit.fetchCategories();

    if (_selectedCategory != null) {
      _productsCubit.fetchProductsByCategory(_selectedCategory!.id);
    } else {
      _productsCubit.fetchCatalog(); // Loads everything including all products
    }
  }

  @override
  void dispose() {
    _categoriesCubit.close();
    _productsCubit.close();
    super.dispose();
  }

  void _onCategorySelected(Category? category) {
    setState(() {
      _selectedCategory = category;
    });
    if (category == null) {
      _productsCubit.fetchCatalog();
    } else {
      _productsCubit.fetchProductsByCategory(category.id);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.categories_title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _categoriesCubit),
          BlocProvider.value(value: _productsCubit),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Sidebar: Filters Sidebar
              BlocBuilder<CatalogCubit, CatalogState>(
                bloc: _categoriesCubit,
                builder: (context, state) {
                  List<Category> categories = [];
                  if (state is CategoriesLoaded) {
                    categories = state.categories;
                  } else if (state is CatalogLoaded) {
                    categories = state.categories;
                  }
                  return WebFiltersSidebar(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                    minPrice: 100,
                    maxPrice: 1000,
                    onPriceRangeChanged: (val) {},
                    cuts: const ['Ribeye', 'Striploin', 'Tenderloin', 'Tomahawk'],
                    selectedCut: null,
                    onCutSelected: (val) {},
                  );
                },
              ),
              const SizedBox(width: 48),

              // Right Main Area: Product Grid
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid Control Header
                    GridControlHeader(
                      selectedSort: null,
                      onSortChanged: (val) {},
                      onSearchChanged: (val) {},
                    ),
                    const SizedBox(height: 24),
                    
                    // Grid
                    Expanded(
                      child: BlocBuilder<CatalogCubit, CatalogState>(
                        bloc: _productsCubit,
                        builder: (context, state) {
                          if (state is ProductsByCategoryLoading ||
                              state is CatalogLoading ||
                              state is CatalogInitial) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is CatalogError) {
                            return Center(
                              child: Text(state.message, style: TextStyle(color: cs.error)),
                            );
                          } else if (state is ProductsByCategoryLoaded || state is CatalogLoaded) {
                            final products = state is ProductsByCategoryLoaded
                                ? state.products
                                : (state as CatalogLoaded).products;

                            if (products.isEmpty) {
                              return Center(child: Text(s.no_products_in_category));
                            }

                            return GridView.builder(
                              itemCount: products.length,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 280,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 0.75,
                              ),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ProductCard(
                                  imageUrl: product.imageUrl,
                                  title: product.title,
                                  subtitle: product.subtitle,
                                  price: product.price,
                                  originalPrice: product.originalPrice,
                                  tag: product.discountTag,
                                  onAddToCart: () {
                                    context.read<CartCubit>().addToCart(productId: product.id, quantity: 1);
                                  },
                                  onTap: () {
                                    context.push(Routes.productDetails, extra: product.id);
                                  },
                                );
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
