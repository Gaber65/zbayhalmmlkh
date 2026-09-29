import 'package:dhabayih_lmamlaka/core/theme/app_icons.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../cart_badge_widget.dart';

class WebNavbarWidget extends StatelessWidget {
  final UserHighlight? userHighlight;
  final String? deliveryLocation;
  final VoidCallback? onLocationTap;

  const WebNavbarWidget({
    super.key,
    this.userHighlight,
    this.deliveryLocation,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _WebNavbarDelegate(
        userHighlight: userHighlight,
        deliveryLocation: deliveryLocation,
        onLocationTap: onLocationTap,
        isArabic: Localizations.localeOf(context).languageCode == 'ar',
        theme: Theme.of(context),
      ),
    );
  }
}

class _WebNavbarDelegate extends SliverPersistentHeaderDelegate {
  final UserHighlight? userHighlight;
  final String? deliveryLocation;
  final VoidCallback? onLocationTap;
  final bool isArabic;
  final ThemeData theme;

  _WebNavbarDelegate({
    required this.userHighlight,
    required this.deliveryLocation,
    required this.onLocationTap,
    required this.isArabic,
    required this.theme,
  });

  @override
  double get minExtent => 78.0;

  @override
  double get maxExtent => 78.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Responsive adaptation inside the navbar for tablet & various laptop widths
    final showCenterLinks = screenWidth >= 1150;
    final showLocationBadge = screenWidth >= 900;
    final showCtaButton = screenWidth >= 768;

    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── 1. Brand Logo & Title ─────────────────────────────────
                InkWell(
                  onTap: () => context.go(Routes.home),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 22,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'ذبائح المملكة' : 'DHABAYIH',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            isArabic ? 'LMAMLAKA' : 'LUXURY MEATS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1.5,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── 2. Center Nav Links (Hidden on compact screens) ──────
                if (showCenterLinks) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNavLink(
                        context,
                        title: S.of(context).home,
                        isActive: true,
                        onTap: () {},
                      ),
                      const SizedBox(width: 28),
                      _buildNavLink(
                        context,
                        title: S.of(context).categories_title,
                        onTap: () => context.push(Routes.categories),
                      ),
                      const SizedBox(width: 28),
                      _buildNavLink(
                        context,
                        title: S.of(context).todays_offers,
                        onTap: () => context.push(Routes.categories),
                      ),
                      const SizedBox(width: 28),
                      _buildNavLink(
                        context,
                        title: isArabic ? 'عن المملكة' : 'About Us',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],

                // ── 3. Actions Row (Location, Icons, CTA Button) ─────────
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Location Picker Badge
                    if (showLocationBadge) ...[
                      InkWell(
                        onTap: onLocationTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppIcons.locationBold,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 130,
                                ),
                                child: Text(
                                  deliveryLocation ??
                                      S.of(context).default_location_mock,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                AppIcons.arrowDown,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Search Action
                    IconButton(
                      onPressed: () => context.push(Routes.search),
                      icon: const Icon(AppIcons.search, size: 22),
                      tooltip: S.of(context).search_hint,
                    ),

                    const SizedBox(width: 2),

                    // Profile / User Action
                    IconButton(
                      onPressed: () => context.go(Routes.profile),
                      icon: const Icon(AppIcons.profileOutline, size: 22),
                      tooltip: S.of(context).profile,
                    ),

                    const SizedBox(width: 2),

                    // Cart Badge
                    CartBadgeWidget(
                      activeCart: userHighlight?.activeCart,
                      onPressed: () => context.go(Routes.cart),
                    ),

                    // Primary CTA Button
                    if (showCtaButton) ...[
                      const SizedBox(width: 14),
                      ElevatedButton(
                        onPressed: () => context.go(Routes.categories),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          elevation: 2,
                          shadowColor: colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isArabic ? 'اطلب الآن' : 'Order Now',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? colorScheme.primary : colorScheme.onSurface,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _WebNavbarDelegate oldDelegate) {
    return oldDelegate.userHighlight != userHighlight ||
        oldDelegate.deliveryLocation != deliveryLocation ||
        oldDelegate.isArabic != isArabic ||
        oldDelegate.theme != theme;
  }
}
