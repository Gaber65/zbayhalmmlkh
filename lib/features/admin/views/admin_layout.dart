import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/colors.dart';
import '../core/admin_i18n.dart';
import '../presentation/manager/admin_categories_cubit.dart';
import '../presentation/manager/admin_dashboard_cubit.dart';
import '../presentation/manager/admin_marketing_cubit.dart';
import '../presentation/manager/admin_options_cubit.dart';
import '../presentation/manager/admin_orders_cubit.dart';
import '../presentation/manager/admin_payments_cubit.dart';
import '../presentation/manager/admin_products_cubit.dart';
import '../presentation/manager/admin_settings_cubit.dart';
import '../presentation/manager/admin_users_cubit.dart';
import '../presentation/views/admin_categories_view.dart';
import '../presentation/views/admin_dashboard_view.dart';
import '../presentation/views/admin_marketing_view.dart';
import '../presentation/views/admin_order_details_screen.dart';
import '../presentation/views/admin_orders_view.dart';
import '../presentation/views/admin_payments_view.dart';
import '../presentation/views/admin_products_view.dart';
import '../presentation/views/admin_users_view.dart';
import '../presentation/views/admin_settings_view.dart';
import '../presentation/manager/admin_branches_cubit.dart';
import '../presentation/views/admin_branches_view.dart';
import '../presentation/widgets/admin_drawer.dart';
import '../presentation/widgets/admin_notifications_sheet.dart';
import 'package:iconly/iconly.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _currentTabIndex = 0;
  final Set<int> _visitedTabs = {0};
  StreamSubscription? _orderAlertSub;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onTabSelected(int idx) {
    if (_currentTabIndex != idx || !_visitedTabs.contains(idx)) {
      setState(() {
        _currentTabIndex = idx;
        _visitedTabs.add(idx);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initAdminServices();
  }

  void _initAdminServices() {
    // 1. Subscribe device to FCM topics for admin order alerts
    NotificationService().subscribeToAdminTopics();

    // 2. Listen to active incoming order notifications to show in-app banner
    _orderAlertSub = NotificationService().adminOrderAlertStream.listen((payload) {
      _showNewOrderBanner(payload['title'] ?? 'طلب جديد وارد!', payload['body'] ?? '');
      if (mounted) {
        context.read<AdminOrdersCubit>().loadOrders(silent: true);
        context.read<AdminDashboardCubit>().loadStats();
      }
    });
  }

  void _showNewOrderBanner(String title, String body) {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.black87,
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'عرض الطلبات',
          textColor: AppColors.primary,
          onPressed: () => _onTabSelected(1),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _orderAlertSub?.cancel();
    super.dispose();
  }

  void _openOrderDetail(int orderId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: getIt<AdminOrdersCubit>(),
          child: AdminOrderDetailsScreen(orderId: orderId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AdminDashboardCubit>()..loadStats()),
        BlocProvider(create: (_) => getIt<AdminOrdersCubit>()..loadOrders()),
        BlocProvider(create: (_) => getIt<AdminProductsCubit>()),
        BlocProvider(create: (_) => getIt<AdminCategoriesCubit>()),
        BlocProvider(create: (_) => getIt<AdminOptionsCubit>()),
        BlocProvider(create: (_) => getIt<AdminMarketingCubit>()),
        BlocProvider(create: (_) => getIt<AdminUsersCubit>()),
        BlocProvider(create: (_) => getIt<AdminPaymentsCubit>()),
        BlocProvider(create: (_) => getIt<AdminBranchesCubit>()),
        BlocProvider(create: (_) => getIt<AdminSettingsCubit>()),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // ── Admin Sidebar Drawer ──────────────────────────────────────────
        drawer: AdminDrawer(
          selectedIndex: _currentTabIndex,
          onSelectIndex: _onTabSelected,
        ),
        // ── Clean Modern Admin AppBar ─────────────────────────────────────
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary, size: 26),
            tooltip: i18n.erpMenu,
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                  color: AppColors.primaryContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset('assets/images/app_logo.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.adminTitle,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getPageTitle(_currentTabIndex, i18n),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // ── Notification Bell with Notifications Center ───────────────
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(IconlyBold.notification, size: 18, color: AppColors.primary),
              ),
              tooltip: i18n.notificationCenter,
              onPressed: () => AdminNotificationsSheet.show(
                context,
                onOpenOrderDetail: _openOrderDetail,
                onNavigateTab: _onTabSelected,
              ),
            ),
            // ── Quick Return to Client Store ──────────────────────────────
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
              ),
              tooltip: i18n.backToStore,
              onPressed: () => context.go(Routes.home),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // ── Body Pages Switcher (Lazy Stack: Only instantiates visited tabs) ─
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            AdminDashboardView(
              onNavigateTab: _onTabSelected,
              onOpenOrderDetail: _openOrderDetail,
            ),
            _visitedTabs.contains(1)
                ? AdminOrdersView(onOpenOrderDetail: _openOrderDetail)
                : const SizedBox.shrink(),
            _visitedTabs.contains(2)
                ? const AdminProductsView()
                : const SizedBox.shrink(),
            _visitedTabs.contains(3)
                ? const AdminCategoriesView()
                : const SizedBox.shrink(),
            _visitedTabs.contains(4)
                ? const AdminUsersView()
                : const SizedBox.shrink(),
            _visitedTabs.contains(5)
                ? const AdminPaymentsView()
                : const SizedBox.shrink(),
            _visitedTabs.contains(6)
                ? const AdminMarketingView()
                : const SizedBox.shrink(),
            _visitedTabs.contains(7)
                ? const AdminBranchesView()
                : const SizedBox.shrink(),
            _visitedTabs.contains(8)
                ? const AdminSettingsView()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(int index, AdminI18n i18n) {
    switch (index) {
      case 0:
        return i18n.menuDashboard;
      case 1:
        return i18n.menuOrders;
      case 2:
        return i18n.menuProducts;
      case 3:
        return i18n.menuCategories;
      case 4:
        return i18n.menuUsers;
      case 5:
        return i18n.menuPayments;
      case 6:
        return i18n.menuMarketing;
      case 7:
        return i18n.isArabic ? 'الفروع ونقاط الاستلام' : 'Branches & Pickups';
      case 8:
        return i18n.menuSettings;
      default:
        return i18n.adminSubtitle;
    }
  }
}
