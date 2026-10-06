import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhabayih_lmamlaka/core/theme/app_icons.dart';
import '../../features/user/favorites/presentation/manager/favorites_cubit.dart';
import '../../features/user/favorites/presentation/manager/favorites_state.dart';
import 'price_widget.dart';

class ProductCard extends StatelessWidget {
  final int? id;
  final dynamic product;
  final String imageUrl;
  final String title;
  final String subtitle;
  final double price;
  final double? originalPrice;
  final String? tag;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    this.id,
    this.product,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.originalPrice,
    this.tag,
    required this.onAddToCart,
    required this.onTap,
    this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasDiscount = originalPrice != null && originalPrice! > price;

    final effectiveId = id ?? (product != null ? (product is int ? product : (product.id ?? (product is Map ? product['id'] : null))) : null);
    bool effectiveIsFav = isFavorite ?? false;
    if (isFavorite == null && effectiveId != null) {
      try {
        final favState = context.watch<FavoritesCubit>().state;
        if (favState is FavoritesLoaded) {
          effectiveIsFav = favState.favoriteIds.contains(effectiveId);
        }
      } catch (_) {}
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        highlightColor: colorScheme.primary.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image & Tag Stack
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: colorScheme.surfaceContainerLow,
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.restaurant_rounded,
                                  color: colorScheme.outline,
                                  size: 32,
                                ),
                              )
                            : Icon(
                                Icons.restaurant_rounded,
                                color: colorScheme.outline,
                                size: 32,
                              ),
                      ),
                    ),
                    // "Open Now" or Discount Tag
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          tag ?? (hasDiscount ? '-${(((originalPrice! - price) / originalPrice!) * 100).round()}%' : 'Open now'),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    // Wishlist Button Top Left
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (onFavoriteToggle != null) {
                              onFavoriteToggle!();
                            } else if (effectiveId != null || product != null) {
                              try {
                                context.read<FavoritesCubit>().toggleFavorite(
                                  product: product ?? effectiveId,
                                  title: title,
                                  price: price,
                                  imageUrl: imageUrl,
                                  subtitle: subtitle,
                                );
                              } catch (_) {}
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: effectiveIsFav
                                  ? Colors.white
                                  : Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                              boxShadow: effectiveIsFav
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.18),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              effectiveIsFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 15,
                              color: effectiveIsFav ? Colors.redAccent : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Rating Badge Bottom Left
                    PositionedDirectional(
                      bottom: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '4.8',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              // Subtitle & Location
              Row(
                children: [
                  Icon(
                    AppIcons.location,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Price & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceWidget(
                          price: price,
                          originalPrice: originalPrice,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: onAddToCart,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
