import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/config/app_config.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';

class WebCategorySectionWidget extends StatelessWidget {
  final List<Category> categories;

  const WebCategorySectionWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'تصفح حسب القسم' : 'Browse by Category',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'أجود اللحوم والذبائح الطازجة المعتمدة التي تثق بها'
                      : 'The highest quality fresh meat and cuts you can trust',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.push(Routes.categories),
              icon: Icon(
                isArabic
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colorScheme.primary,
              ),
              label: Text(
                isArabic ? 'عرض كل الأقسام' : 'View All Categories',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Circular Categories Row / Wrap
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 32),
            itemBuilder: (context, index) {
              final category = categories[index];
              final imageUrl = category.imageUrl.isNotEmpty
                  ? (category.imageUrl.startsWith('http')
                        ? category.imageUrl
                        : "${AppConfig.baseUrl}/${category.imageUrl}")
                  : "";

              return _WebCategoryCircleItem(
                label: category.name,
                imageUrl: imageUrl,
                onTap: () {
                  context.push(Routes.productsByCategory, extra: category);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 36),
      ],
    );
  }
}

class _WebCategoryCircleItem extends StatefulWidget {
  final String label;
  final String imageUrl;
  final VoidCallback onTap;

  const _WebCategoryCircleItem({
    required this.label,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_WebCategoryCircleItem> createState() => _WebCategoryCircleItemState();
}

class _WebCategoryCircleItemState extends State<_WebCategoryCircleItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Image Container
              AnimatedScale(
                scale: _isHovered ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutQuad,
                child: Container(
                  width: 115,
                  height: 115,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface,
                    border: Border.all(
                      color: _isHovered
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: _isHovered ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered
                            ? colorScheme.primary.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: _isHovered ? 18 : 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: colorScheme.surfaceContainerLow,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.restaurant_menu_rounded,
                              color: colorScheme.primary,
                              size: 36,
                            ),
                          )
                        : Icon(
                            Icons.restaurant_menu_rounded,
                            color: colorScheme.primary,
                            size: 36,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Category Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: _isHovered ? FontWeight.w800 : FontWeight.w700,
                  color: _isHovered
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontSize: 14,
                ),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
