import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'price_widget.dart';

class OfferCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final double originalPrice;
  final String discountTag;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discountTag,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 176, // 44 in Tailwind * 4
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Discount Badge
            SizedBox(
              height: 176, // 44 in Tailwind * 4
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceContainer,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        discountTag,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  PriceWidget(
                    price: price,
                    originalPrice: originalPrice,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    originalStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Add to Cart Button (Outlined)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onAddToCart,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
