import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/widgets/product_card.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../../../domain/entities/category.dart';
import '../../../manager/catalog_cubit.dart';
import '../../../manager/catalog_state.dart';
import '../../../../../cart/presentation/manager/cart_cubit.dart';

class ProductsByCategoryMobileView extends StatefulWidget {
  final Category category;

  const ProductsByCategoryMobileView({super.key, required this.category});

  @override
  State<ProductsByCategoryMobileView> createState() => _ProductsByCategoryMobileViewState();
}

class _ProductsByCategoryMobileViewState extends State<ProductsByCategoryMobileView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CatalogCubit>().fetchProductsByCategory(widget.category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          widget.category.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          if (state is ProductsByCategoryLoading || state is CatalogInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CatalogError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<CatalogCubit>().fetchProductsByCategory(widget.category.id),
                      child: Text(S.of(context).retry_button),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProductsByCategoryLoaded || state is CatalogLoaded) {
            final products = state is ProductsByCategoryLoaded
                ? state.products
                : (state as CatalogLoaded).products;

            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).no_products_in_category,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<CatalogCubit>().fetchProductsByCategory(widget.category.id),
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
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
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
