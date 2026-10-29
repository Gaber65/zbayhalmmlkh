import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../routes/routes.dart';
import '../utils/whatsapp_helper.dart';
import '../../features/user/cart/presentation/manager/cart_cubit.dart';
import '../../features/user/cart/presentation/manager/cart_state.dart';
import '../../features/user/home/presentation/manager/home_cubit.dart';
import '../../features/user/home/presentation/manager/home_state.dart';
import '../../features/user/home/presentation/views/widgets/kingdom/kingdom_design.dart';
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

  int _resolveCartBadgeCount(BuildContext context) {
    try {
      final cartState = context.watch<CartCubit>().state;
      if (cartState is CartLoaded) {
        return cartState.cart.itemCount;
      }
      if (cartState is CartItemAdded) {
        return cartState.cart.itemCount;
      }
    } catch (_) {}

    try {
      final homeState = context.watch<HomeCubit>().state;
      if (homeState is HomeLoaded) {
        return homeState.homeData.userHighlight?.activeCart?.lineCount ?? 0;
      }
    } catch (_) {}

    return 0;
  }

  @override
  Widget build(BuildContext context) {
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

    final cartBadgeCount = _resolveCartBadgeCount(context);
    final p = KPalette.of(context);

    return Scaffold(
      extendBody: false,
      backgroundColor: p.paper,
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        heroTag: 'kingdom_whatsapp_fab',
        onPressed: () {
          WhatsAppHelper.launchSupportChat();
        },
        backgroundColor: const Color(0xFF25D366),
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: kTr(context, 'تواصل عبر واتساب', 'WhatsApp Support'),
        child: SvgPicture.asset(
          'assets/images/whatsapp_logo.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
      bottomNavigationBar: !ResponsiveLayout.isMobile(context)
          ? null
          : KingdomBottomNavigationBar(
              currentIndex: currentIndex,
              cartBadgeCount: cartBadgeCount,
              onItemTapped: _onItemTapped,
            ),
    );
  }
}

/// Bottom navigation bar matching `<nav class="bottom-nav">` in `design_reference/index.html`.
class KingdomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int cartBadgeCount;
  final ValueChanged<int> onItemTapped;

  const KingdomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.cartBadgeCount = 0,
    required this.onItemTapped,
  });

  static const List<({KIcon icon, String labelAr, String labelEn})> _items = [
    (icon: KIcon.home, labelAr: 'الرئيسية', labelEn: 'Home'),
    (icon: KIcon.grid, labelAr: 'الأقسام', labelEn: 'Categories'),
    (icon: KIcon.bag, labelAr: 'السلة', labelEn: 'Cart'),
    (icon: KIcon.orders, labelAr: 'طلباتي', labelEn: 'Orders'),
    (icon: KIcon.user, labelAr: 'حسابي', labelEn: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomPad = bottomInset > 9 ? bottomInset : 9.0;

    return Container(
      decoration: BoxDecoration(
        color: p.navBg,
        border: Border(top: BorderSide(color: p.line, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(10, 7, 10, bottomPad),
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final label = kTr(context, item.labelAr, item.labelEn);
          final isSelected = currentIndex == index;
          final badge = index == 2 ? cartBadgeCount : 0;

          return Expanded(
            child: KTap(
              onTap: () => onItemTapped(index),
              radius: BorderRadius.circular(10),
              selected: isSelected,
              semanticLabel: label,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 46,
                        height: 25,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 25,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? p.navActivePill
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: KSvgIcon(
                                item.icon,
                                size: 22,
                                color: isSelected
                                    ? p.red
                                    : (p.isDark
                                        ? p.inkMuted
                                        : const Color(0xFF85897F)),
                              ),
                            ),
                            if (badge > 0)
                              PositionedDirectional(
                                top: -3,
                                end: 4,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 15,
                                    minHeight: 15,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.red,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: p.surface,
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    badge > 99 ? '99+' : '$badge',
                                    style: kText(
                                      9,
                                      weight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: kText(
                          10,
                          weight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? p.red
                              : (p.isDark
                                  ? p.inkMuted
                                  : const Color(0xFF85897F)),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
