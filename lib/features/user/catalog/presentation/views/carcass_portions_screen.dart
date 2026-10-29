import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';

/// Screen displayed when selecting a carcass breed (نعيمي, نجدي, حري, تيس...)
/// Allowing the customer to choose between (كامل, نصف, ربع)
/// Fully supports Multi-language (AR/EN), Dark & Light theme,
/// and uses the official Dhabayih Al-Mamlaka logo for image fallbacks.
class CarcassPortionsScreen extends StatelessWidget {
  final Product product;

  const CarcassPortionsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final portions = product.effectivePortions;

    final displayTitle = isAr
        ? (product.titleAr ?? product.title)
        : (product.titleEn ?? product.title);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest : cs.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_rounded, size: 20, color: cs.onSurface),
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          displayTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Image & Banner
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (product.imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: cs.surfaceContainerHighest),
                        errorWidget: (_, _, _) => _fallbackLogoContainer(cs, isDark),
                      )
                    else
                      _fallbackLogoContainer(cs, isDark),
                    // Gradient scrim
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.78),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B1B30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isAr ? 'طازج ومذبوح يومياً' : 'Fresh Daily Slaughter',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Section Header
              Text(
                isAr ? 'اختيار تقسيم الذبيحة' : 'Choose Carcass Portion',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? cs.primary : const Color(0xFF9B1B30),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAr
                    ? 'اختر التقسيم المطلوب للمتابعة إلى تفاصيل التقطيع والتغليف والأحجام'
                    : 'Select your desired portion to proceed to cutting, packaging, and sizes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              // 3. Portions Comparative Cards (Row of 3 cards)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: portions.map((portion) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _PortionCard(
                        item: portion,
                        isAr: isAr,
                        isDark: isDark,
                        onTap: () {
                          context.push(
                            Routes.productDetails,
                            extra: {
                              'product': product,
                              'portion': portion.type,
                            },
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // 4. Guarantee / Trust Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                      : const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? cs.outlineVariant.withValues(alpha: 0.3)
                        : Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: isDark ? Colors.amber : const Color(0xFFD97706),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'ضمان الجودة والذبح الشرعي' : 'Quality & Halal Slaughter Guarantee',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? cs.onSurface : const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAr
                                ? 'ذبائح بلدية ومستوردة طازجة تُذبح يومياً تحت إشراف أطباء بيطريين مختصين.'
                                : 'Fresh livestock slaughtered daily under specialized veterinary supervision.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? cs.onSurfaceVariant : Colors.brown.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackLogoContainer(ColorScheme cs, bool isDark) {
    return Container(
      color: isDark ? cs.surfaceContainerHighest : const Color(0xFFFBF6EF),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _PortionCard extends StatelessWidget {
  final ProductPortion item;
  final bool isAr;
  final bool isDark;
  final VoidCallback onTap;

  const _PortionCard({
    required this.item,
    required this.isAr,
    required this.isDark,
    required this.onTap,
  });

  String get _displayName {
    if (item.type == 'full') return isAr ? 'كامل' : 'Whole';
    if (item.type == 'half') return isAr ? 'نصف' : 'Half';
    if (item.type == 'quarter') return isAr ? 'ربع' : 'Quarter';
    return item.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final portionName = _displayName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? cs.surfaceContainerHighest : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? cs.outlineVariant.withValues(alpha: 0.4)
                  : const Color(0xFF9B1B30).withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Portion Title
              Text(
                portionName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? cs.primary : const Color(0xFF9B1B30),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Image Thumbnail with Official Dhabayih Logo fallback
              Container(
                height: 85,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? cs.surface : const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: cs.surfaceContainerHighest),
                        errorWidget: (_, _, _) => _fallbackLogo(cs, isDark),
                      )
                    : _fallbackLogo(cs, isDark),
              ),

              const SizedBox(height: 10),

              // Starting Price
              Text(
                isAr
                    ? 'من ${item.startingPrice.toStringAsFixed(0)} ر.س'
                    : 'From ${item.startingPrice.toStringAsFixed(0)} SAR',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Action Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B1B30),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  isAr ? 'اختيار $portionName' : 'Select $portionName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackLogo(ColorScheme cs, bool isDark) {
    return Container(
      color: isDark ? cs.surface : const Color(0xFFFBF6EF),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
