import 'dart:async';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/config/app_config.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';

class WebHeroSectionWidget extends StatefulWidget {
  final List<BannerEntity> banners;

  const WebHeroSectionWidget({super.key, required this.banners});

  @override
  State<WebHeroSectionWidget> createState() => _WebHeroSectionWidgetState();
}

class _WebHeroSectionWidgetState extends State<WebHeroSectionWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // High-res luxury meat background if API banners are missing or loading
  static const String _fallbackImageUrl =
      'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1600&q=80';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.banners.length > 1 && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasBanners =
        widget.banners.isNotEmpty && _currentPage < widget.banners.length;
    final itemCount = widget.banners.isNotEmpty ? widget.banners.length : 1;
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    return Container(
      width: double.infinity,
      height: isCompact ? 420 : 460,
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: itemCount,
            itemBuilder: (context, index) {
              String imageUrl = _fallbackImageUrl;
              if (widget.banners.isNotEmpty && index < widget.banners.length) {
                final rawUrl = widget.banners[index].imageUrl;
                if (rawUrl.isNotEmpty) {
                  imageUrl = rawUrl.startsWith('http')
                      ? rawUrl
                      : "${AppConfig.baseUrl}/$rawUrl";
                }
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ),
                    errorWidget: (context, url, error) => CachedNetworkImage(
                      imageUrl: _fallbackImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark vignette & aesthetic gradient scrim
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        end: isArabic
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.60),
                          Colors.black.withValues(alpha: 0.15),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Floating Hero Content Box
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 32.0 : 56.0,
                vertical: 32.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isCompact ? 480 : 580),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Tag Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: colorScheme.onPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isArabic
                                ? 'جودة طازجة ומضمونة ١٠٠٪'
                                : '100% PREMIUM ORGANIC QUALITY',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Title
                    Text(
                      hasBanners && widget.banners[_currentPage].name.isNotEmpty
                          ? widget.banners[_currentPage].name
                          : (isArabic
                                ? 'أجود اللحوم والذبائح الطازجة حتى باب بيتك'
                                : 'Authentic Fresh Sacrifices & Custom Meats'),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        fontSize: isCompact ? 32 : 40,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Subtitle
                    Text(
                      isArabic
                          ? 'اختر ذبيحتك المفضلة مع تقطيع وتغليف مخصص حسب طلبك، ونقوم بتوصيلها في سيارات مبردة بأعلى معايير النظافة والجودة.'
                          : 'Select premium livestock with tailored butchery options, vacuum packaging, and rapid refrigerated express transport directly to your doorstep.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: isCompact ? 14 : 16,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Call to Action Buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.push(Routes.categories),
                          icon: const Icon(
                            Icons.shopping_cart_checkout_rounded,
                            size: 20,
                          ),
                          label: Text(
                            isArabic ? 'تصفح الأصناف' : 'SHOP NOW',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 18,
                            ),
                            elevation: 4,
                            shadowColor: colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                        OutlinedButton(
                          onPressed: () => context.push(Routes.search),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isArabic ? 'استعرض العروض' : 'EXPLORE DEALS',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pagination indicators if multiple banners exist
          if (itemCount > 1)
            Positioned(
              bottom: 24,
              right: isArabic ? null : 32,
              left: isArabic ? 32 : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  itemCount,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 32 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? colorScheme.primary
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
