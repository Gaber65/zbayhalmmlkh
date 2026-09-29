import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/core/widgets/responsive_layout.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/presentation/manager/catalog_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/presentation/manager/catalog_state.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_state.dart';
import 'widgets/mobile/product_mobile_view.dart';
import 'widgets/web/product_web_view.dart';

class ProductDetailsScreen extends StatefulWidget {
  final dynamic product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int? get _productId {
    final p = widget.product;
    if (p is int) return p;
    if (p is Map) return p['id'] as int?;
    if (p is Product) return p.id;
    return null;
  }

  Product? _inlineProduct() {
    if (widget.product is Product) return widget.product as Product;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final preloaded = _inlineProduct();
    final productId = _productId;

    if (productId != null) {
      return BlocProvider(
        create: (_) => getIt<CatalogCubit>()..fetchProductById(productId),
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            if (state is ProductDetailLoaded) {
              final loaded = state.product;
              final effectiveProduct = (preloaded != null && preloaded.isOnOffer && preloaded.offerPrice != null)
                  ? Product(
                      id: loaded.id,
                      title: loaded.title,
                      titleAr: loaded.titleAr,
                      titleEn: loaded.titleEn,
                      subtitle: loaded.subtitle,
                      description: loaded.description,
                      sku: loaded.sku,
                      barcode: loaded.barcode,
                      price: loaded.price,
                      purchasePrice: loaded.purchasePrice,
                      originalPrice: preloaded.price > 0 ? preloaded.price : loaded.price,
                      offerPrice: preloaded.offerPrice ?? loaded.offerPrice,
                      profit: loaded.profit,
                      profitPercentage: loaded.profitPercentage,
                      discountType: preloaded.discountType ?? loaded.discountType,
                      discountValue: preloaded.discountValue ?? loaded.discountValue,
                      offerStartDate: loaded.offerStartDate,
                      offerEndDate: loaded.offerEndDate,
                      isOnOffer: true,
                      imageUrl: loaded.imageUrl.isNotEmpty ? loaded.imageUrl : preloaded.imageUrl,
                      discountTag: preloaded.discountTag ?? loaded.discountTag,
                      isOffer: true,
                      isFeatured: loaded.isFeatured,
                      isBestSeller: loaded.isBestSeller,
                      isAvailable: loaded.isAvailable,
                      active: loaded.active,
                      stockQuantity: loaded.stockQuantity,
                      minimumStock: loaded.minimumStock,
                      weightKg: loaded.weightKg,
                      preparationTimeMin: loaded.preparationTimeMin,
                      categoryId: loaded.categoryId,
                      categoryName: loaded.categoryName,
                      loyaltyPoints: loaded.loyaltyPoints,
                      hasSizes: loaded.hasSizes,
                      sizes: loaded.sizes,
                      calories: loaded.calories,
                      cuttingOptions: loaded.cuttingOptions.isNotEmpty
                          ? loaded.cuttingOptions
                          : preloaded.cuttingOptions,
                      packagingOptions: loaded.packagingOptions.isNotEmpty
                          ? loaded.packagingOptions
                          : preloaded.packagingOptions,
                      excludedParts: loaded.excludedParts.isNotEmpty
                          ? loaded.excludedParts
                          : preloaded.excludedParts,
                      galleryImages: loaded.galleryImages.isNotEmpty
                          ? loaded.galleryImages
                          : preloaded.galleryImages,
                    )
                  : loaded;
              return _buildWithProduct(effectiveProduct);
            } else if (state is ProductDetailError) {
              if (preloaded != null) {
                return _buildWithProduct(preloaded);
              }
              return _buildErrorScaffold(state.message, context);
            }
            if (preloaded != null) {
              return _buildWithProduct(preloaded);
            }
            return _buildLoadingScaffold();
          },
        ),
      );
    }

    if (preloaded != null) {
      return _buildWithProduct(preloaded);
    }

    return _buildErrorScaffold(S.of(context).product_not_found, context);
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(S.of(context).loading_product,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String message, BuildContext ctx) {
    return Scaffold(
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => ctx.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: Theme.of(ctx).colorScheme.error),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyLarge),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ctx
                    .read<CatalogCubit>()
                    .fetchProductById(_productId!),
                icon: const Icon(Icons.refresh),
                label: Text(S.of(ctx).retry_button),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithProduct(Product product) {
    final cs = Theme.of(context).colorScheme;
    final s = S.of(context);

    return BlocProvider(
      create: (_) => getIt<CartCubit>(),
      child: BlocListener<CartCubit, CartState>(
        listener: (ctx, state) {
          if (state is CartItemAdded) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(s.cart_add_success),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
            ctx.pop();
          } else if (state is CartItemAddError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        child: ResponsiveLayout(
          mobile: ProductMobileView(product: product),
          desktop: ProductWebView(product: product),
        ),
      ),
    );
  }
}
