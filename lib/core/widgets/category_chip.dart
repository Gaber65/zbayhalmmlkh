import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryChip extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final double width;
  final double height;

  const CategoryChip({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.width = 84,
    this.height = 92,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(6),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, error, stackTrace) => Icon(
                            Icons.restaurant_menu_rounded,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        )
                      : Icon(
                          Icons.restaurant_menu_rounded,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
