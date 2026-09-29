import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';

class WebFeaturedCollectionsWidget extends StatelessWidget {
  const WebFeaturedCollectionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isNarrow = MediaQuery.sizeOf(context).width < 950;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                isArabic ? 'مجموعات مختارة وعروض خاصة' : 'Featured Collections & Bundles',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Responsive Bento Layout
        if (isNarrow)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 360,
                child: _BentoPromoCard(
                  imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=1000&q=80',
                  title: isArabic ? 'بكجات المناسبات والولائم الفاخرة' : 'Feast & Party Luxury Packages',
                  subtitle: isArabic
                      ? 'تشكيلة متكاملة من الذبائح الطازجة المجهزة خصيصاً للمناسبات والولائم بأعلى مستويات الجودة.'
                      : 'Curated sets of authentic livestock specially butchered and prepared for gatherings and feasts.',
                  buttonText: isArabic ? 'تصفح البكجات' : 'Explore Collection',
                  isLarge: false,
                  onTap: () => context.push(Routes.categories),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: _BentoPromoCard(
                  imageUrl: 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?auto=format&fit=crop&w=800&q=80',
                  title: isArabic ? 'تقطيع وتغليف فاكيوم احترافي' : 'Custom Cut & Vacuum Sealing',
                  subtitle: isArabic
                      ? 'خيارات تقطيع متنوعة وتغليف مفرغ من الهواء للحفاظ على طازجية اللحم.'
                      : 'Tailored cutting styles with vacuum packing to preserve extreme freshness.',
                  buttonText: isArabic ? 'اطلب الآن' : 'Order Now',
                  isLarge: false,
                  onTap: () => context.push(Routes.categories),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: _BentoPromoCard(
                  imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
                  title: isArabic ? 'توصيل مبرد سريع ومضمون' : 'Refrigerated Express Delivery',
                  subtitle: isArabic
                      ? 'أسطول مبرد لنقل طلبك بأمان وفي درجة حرارة مثالية.'
                      : 'Specialized cold climate transport fleet bringing orders right to your table.',
                  buttonText: isArabic ? 'المزيد عن الشحنات' : 'Learn More',
                  isLarge: false,
                  onTap: () => context.push(Routes.categories),
                ),
              ),
            ],
          )
        else
          SizedBox(
            height: 520,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Large Card (50% width)
                Expanded(
                  flex: 12,
                  child: _BentoPromoCard(
                    imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=1000&q=80',
                    title: isArabic ? 'بكجات المناسبات والولائم الفاخرة' : 'Feast & Party Luxury Packages',
                    subtitle: isArabic
                        ? 'تشكيلة متكاملة من الذبائح الطازجة المجهزة خصيصاً للمناسبات والولائم بأعلى مستويات الجودة.'
                        : 'Curated sets of authentic livestock specially butchered and prepared for gatherings and feasts.',
                    buttonText: isArabic ? 'تصفح البكجات' : 'Explore Collection',
                    isLarge: true,
                    onTap: () => context.push(Routes.categories),
                  ),
                ),

                const SizedBox(width: 24),

                // Right Stacked Cards (50% width)
                Expanded(
                  flex: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _BentoPromoCard(
                          imageUrl: 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?auto=format&fit=crop&w=800&q=80',
                          title: isArabic ? 'تقطيع وتغليف فاكيوم احترافي' : 'Custom Cut & Vacuum Sealing',
                          subtitle: isArabic
                              ? 'خيارات تقطيع متنوعة وتغليف مفرغ من الهواء للحفاظ على طازجية اللحم.'
                              : 'Tailored cutting styles with vacuum packing to preserve extreme freshness.',
                          buttonText: isArabic ? 'اطلب الآن' : 'Order Now',
                          isLarge: false,
                          onTap: () => context.push(Routes.categories),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _BentoPromoCard(
                          imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
                          title: isArabic ? 'توصيل مبرد سريع ومضمون' : 'Refrigerated Express Delivery',
                          subtitle: isArabic
                              ? 'أسطول مبرد لنقل طلبك بأمان وفي درجة حرارة مثالية.'
                              : 'Specialized cold climate transport fleet bringing orders right to your table.',
                          buttonText: isArabic ? 'المزيد عن الشحنات' : 'Learn More',
                          isLarge: false,
                          onTap: () => context.push(Routes.categories),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 48),
      ],
    );
  }
}

class _BentoPromoCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isLarge;
  final VoidCallback onTap;

  const _BentoPromoCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.isLarge,
    required this.onTap,
  });

  @override
  State<_BentoPromoCard> createState() => _BentoPromoCardState();
}

class _BentoPromoCardState extends State<_BentoPromoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.16 : 0.08),
                blurRadius: _isHovered ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Animated Background Zoom on Hover
              AnimatedScale(
                scale: _isHovered ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: colorScheme.surfaceContainerHigh,
                  ),
                ),
              ),

              // Gradient Scrim Overlay for Legibility
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.90),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // Content Typography & Action Button
              Padding(
                padding: EdgeInsets.all(widget.isLarge ? 36.0 : 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: (widget.isLarge ? theme.textTheme.headlineMedium : theme.textTheme.titleLarge)?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        fontSize: widget.isLarge ? 26 : 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: widget.isLarge ? 15 : 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isHovered ? colorScheme.primary : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isHovered ? colorScheme.primary : Colors.white.withValues(alpha: 0.6),
                        ),
                        boxShadow: _isHovered
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.buttonText,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isArabic ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
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
