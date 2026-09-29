import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/cart_badge_widget.dart';
import 'package:dhabayih_lmamlaka/features/user/offers/domain/entities/offer_entity.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';

class OfferDetailsScreen extends StatelessWidget {
  final OfferEntity offer;

  const OfferDetailsScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          offer.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          CartBadgeWidget(
            onPressed: () => context.go(Routes.cart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Promotional Header Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  if (offer.bannerImageUrl != null && offer.bannerImageUrl!.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: offer.bannerImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildFallbackHeader(cs),
                      ),
                    )
                  else
                    _buildFallbackHeader(cs),

                  // Overlay gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Offer Badge
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        offer.badgeText.isNotEmpty ? offer.badgeText : 'عرض خاص',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Offer Details at Bottom of Banner
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (offer.subtitle != null && offer.subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            offer.subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Offer Description (if any)
          if (offer.description != null && offer.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    offer.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

          // 3. Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'المنتجات المشمولة بالعرض (${offer.products.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Products Grid
          if (offer.products.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'لا توجد منتجات مشمولة بهذا العرض حالياً',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = offer.products[index];
                    return _buildProductCard(context, product);
                  },
                  childCount: offer.products.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildFallbackHeader(ColorScheme cs) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.onPrimaryFixed, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.local_offer, size: 56, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Calculate discounted price
    double originalPrice = product.price;
    double discountedPrice = originalPrice;
    if (offer.discountType == 'percentage') {
      discountedPrice = originalPrice * (1.0 - (offer.discountValue / 100.0));
    } else {
      discountedPrice = (originalPrice - offer.discountValue).clamp(0.0, double.infinity);
    }

    return GestureDetector(
      onTap: () {
        final productWithOffer = Product(
          id: product.id,
          title: product.title,
          titleAr: product.titleAr,
          titleEn: product.titleEn,
          subtitle: product.subtitle,
          description: product.description,
          sku: product.sku,
          barcode: product.barcode,
          price: originalPrice,
          purchasePrice: product.purchasePrice,
          originalPrice: originalPrice,
          offerPrice: discountedPrice,
          profit: product.profit,
          profitPercentage: product.profitPercentage,
          discountType: offer.discountType,
          discountValue: offer.discountValue,
          offerStartDate: offer.startDate,
          offerEndDate: offer.endDate,
          isOnOffer: true,
          imageUrl: product.imageUrl,
          discountTag: offer.badgeText.isNotEmpty ? offer.badgeText : null,
          isOffer: true,
          isFeatured: product.isFeatured,
          isBestSeller: product.isBestSeller,
          isAvailable: product.isAvailable,
          active: product.active,
          stockQuantity: product.stockQuantity,
          minimumStock: product.minimumStock,
          weightKg: product.weightKg,
          preparationTimeMin: product.preparationTimeMin,
          categoryId: product.categoryId,
          categoryName: product.categoryName,
          loyaltyPoints: product.loyaltyPoints,
          cuttingOptions: product.cuttingOptions,
          packagingOptions: product.packagingOptions,
          excludedParts: product.excludedParts,
          galleryImages: product.galleryImages,
        );
        context.push(Routes.productDetails, extra: productWithOffer);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: cs.surfaceContainerHighest),
                          errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey),
                        )
                      : Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                            size: 36,
                          ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offer.badgeText.isNotEmpty ? offer.badgeText : 'عرض',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discounted price
                        Text(
                          '${discountedPrice.toStringAsFixed(0)} ر.س',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        // Original price
                        Text(
                          '${originalPrice.toStringAsFixed(0)} ر.س',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
