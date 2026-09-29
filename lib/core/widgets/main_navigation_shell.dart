import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../routes/routes.dart';
import '../theme/app_icons.dart';
import '../utils/whatsapp_helper.dart';
import 'responsive_layout.dart';

class MainNavigationShell extends StatefulWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.categories);
        break;
      case 2:
        context.go(Routes.cart);
        break;
      case 3:
        context.go(Routes.orders);
        break;
      case 4:
        context.go(Routes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate current selection index from GoRouter path
    final String location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location.startsWith(Routes.home)) {
      currentIndex = 0;
    } else if (location.startsWith(Routes.categories)) {
      currentIndex = 1;
    } else if (location.startsWith(Routes.cart)) {
      currentIndex = 2;
    } else if (location.startsWith(Routes.orders)) {
      currentIndex = 3;
    } else if (location.startsWith(Routes.profile)) {
      currentIndex = 4;
    }

    const int totalItems = 5;

    return Scaffold(
      extendBody: true,
      body: widget.child,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          heroTag: 'whatsapp_support_fab',
          onPressed: () => WhatsAppHelper.launchSupportChat(),
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          tooltip: 'تواصل عبر واتساب',
          child: SvgPicture.asset(
            'assets/images/whatsapp_logo.svg',
            width: 28,
            height: 28,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: !ResponsiveLayout.isMobile(context)
          ? null
          : SafeArea(
              top: false,
              bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12, top: 4),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(totalItems, (index) {
                final isSelected = currentIndex == index;

                late final IconData icon;
                late final IconData selectedIcon;
                late final String label;

                switch (index) {
                  case 0:
                    icon = AppIcons.homeOutline;
                    selectedIcon = AppIcons.homeBold;
                    label = S.of(context).home;
                    break;
                  case 1:
                    icon = AppIcons.categoryOutline;
                    selectedIcon = AppIcons.categoryBold;
                    label = S.of(context).categories_title;
                    break;
                  case 2:
                    icon = AppIcons.bagOutline;
                    selectedIcon = AppIcons.bagBold;
                    label = S.of(context).my_cart;
                    break;
                  case 3:
                    icon = AppIcons.documentOutline;
                    selectedIcon = AppIcons.documentBold;
                    label = S.of(context).orders_title;
                    break;
                  case 4:
                    icon = AppIcons.profileOutline;
                    selectedIcon = AppIcons.profileBold;
                    label = S.of(context).profile;
                    break;
                }

                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: label,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 16 : 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? selectedIcon : icon,
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
