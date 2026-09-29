import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/catalog/domain/entities/category.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_categories_cubit.dart';
import '../manager/admin_dashboard_cubit.dart';
import '../manager/admin_marketing_cubit.dart';
import '../manager/admin_orders_cubit.dart';
import '../manager/admin_products_cubit.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/broadcast_notification_dialog.dart';
import '../widgets/product_form_dialog.dart';

class AdminDashboardView extends StatelessWidget {
  final Function(int targetTabIndex) onNavigateTab;
  final Function(int orderId) onOpenOrderDetail;

  const AdminDashboardView({
    super.key,
    required this.onNavigateTab,
    required this.onOpenOrderDetail,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = AdminI18n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminDashboardCubit>().loadStats();
        context.read<AdminOrdersCubit>().loadOrders(silent: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── KPI Statistics Cards ──────────────────────────────────────
            BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
              builder: (context, state) {
                final stats = state is AdminDashboardLoaded ? state.stats : null;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            title: i18n.isArabic ? 'إجمالي المبيعات' : 'Total Revenue',
                            value: stats != null
                                ? '${stats.monthlySales.toStringAsFixed(0)} ${i18n.sar}'
                                : '0 ${i18n.sar}',
                            subtitle: '${i18n.isArabic ? 'الشهر الحالي' : 'This Month'}: ${stats?.currentMonthRevenue.toStringAsFixed(0) ?? '0'} ${i18n.sar}',
                            icon: IconlyLight.wallet,
                            gradientColors: const [Color(0xFFE53935), Color(0xFFEF5350)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminStatCard(
                            title: i18n.isArabic ? 'إجمالي الطلبات' : 'Total Orders',
                            value: stats?.totalOrders.toString() ?? '0',
                            subtitle: '${i18n.isArabic ? 'هذا الشهر' : 'This Month'}: ${stats?.currentMonthOrders ?? 0}',
                            icon: IconlyLight.bag,
                            gradientColors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
                            onTap: () => onNavigateTab(1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            title: i18n.isArabic ? 'طلبات بانتظار الإجراء' : 'Pending Action',
                            value: stats != null
                                ? '${stats.pendingOrders + stats.preparingOrders}'
                                : '0',
                            subtitle: i18n.isArabic ? 'مراجعة وتجهيز فوري' : 'Review & prepare',
                            icon: IconlyLight.time_circle,
                            gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                            onTap: () => onNavigateTab(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminStatCard(
                            title: i18n.totalProducts,
                            value: stats?.totalProducts.toString() ?? '0',
                            subtitle: '${i18n.isArabic ? 'نواقص المخزون' : 'Low Stock'}: ${stats?.lowStockCount ?? 0}',
                            icon: IconlyLight.work,
                            gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                            onTap: () => onNavigateTab(2),
                          ),
                        ),
                      ],
                    ),

                    if (stats != null && (stats.revenueProgress > 0 || stats.ordersProgress > 0)) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  i18n.isArabic ? 'معدل إنجاز مبيعات الشهر' : 'Monthly Sales Progress',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  '${stats.revenueProgress}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: (stats.revenueProgress / 100).clamp(0.0, 1.0),
                                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Top Selling Products Leaderboard
                    if (stats != null && stats.topProducts.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            i18n.isArabic ? 'المنتجات الأكثر مبيعاً 🏆' : 'Top Selling Products 🏆',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${stats.topProducts.length} ${i18n.isArabic ? 'منتجات' : 'items'}',
                            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stats.topProducts.take(4).length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                          itemBuilder: (context, index) {
                            final item = stats.topProducts[index];
                            return ListTile(
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? AppColors.primary.withValues(alpha: 0.15)
                                      : (isDark ? Colors.white10 : Colors.grey.shade100),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: index == 0 ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('${item['units'] ?? 0} ${i18n.isArabic ? 'قطعة مباعة' : 'units sold'}', style: const TextStyle(fontSize: 11)),
                              trailing: Text(
                                '${item['formatted_sales'] ?? '${item['sales'] ?? 0} ${i18n.sar}'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    // Inventory Health Summary (Screenshot 8)
                    if (stats != null && stats.inventoryData.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            i18n.isArabic ? 'ملخص صحة المخزون' : 'Inventory Summary',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${i18n.isArabic ? 'نسبة التغطية' : 'Coverage'}: ${stats.inventoryData['stock_coverage'] ?? 100}%',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMiniStatBox(
                                    label: i18n.isArabic ? 'إجمالي العناصر' : 'Total Items',
                                    value: '${stats.inventoryData['total'] ?? stats.totalProducts}',
                                    color: const Color(0xFF3B82F6),
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildMiniStatBox(
                                    label: i18n.isArabic ? 'مخزون منخفض' : 'Low Stock',
                                    value: '${stats.inventoryData['low_stock'] ?? stats.lowStockCount}',
                                    color: const Color(0xFFF59E0B),
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildMiniStatBox(
                                    label: i18n.isArabic ? 'غير متوفر' : 'Out of Stock',
                                    value: '${stats.inventoryData['out_of_stock'] ?? 0}',
                                    color: const Color(0xFFEF4444),
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ((stats.inventoryData['stock_coverage'] ?? 100) / 100).toDouble().clamp(0.0, 1.0),
                                backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Quick Shortcuts ───────────────────────────────────────────
            Text(
              i18n.quickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickAction(
                  context: context,
                  label: i18n.addProduct,
                  icon: IconlyLight.plus,
                  color: AppColors.primary,
                  onTap: () {
                    final catsState = context.read<AdminCategoriesCubit>().state;
                    final categories = catsState is AdminCategoriesLoaded ? catsState.categories : <Category>[];
                    showDialog(
                      context: context,
                      builder: (_) => ProductFormDialog(
                        categories: categories,
                        onSave: (data) async {
                          final success = await context.read<AdminProductsCubit>().createProduct(data);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(i18n.saveSuccess)),
                            );
                          }
                          return success;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context: context,
                  label: i18n.viewOrders,
                  icon: IconlyLight.bag,
                  color: const Color(0xFF3B82F6),
                  onTap: () => onNavigateTab(1),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context: context,
                  label: i18n.tabCategories,
                  icon: IconlyLight.category,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => onNavigateTab(3),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context: context,
                  label: i18n.isArabic ? 'إشعار للعملاء' : 'Push Notification',
                  icon: IconlyBold.notification,
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => BroadcastNotificationDialog(
                        onSend: (title, body, topic) async {
                          return await context.read<AdminMarketingCubit>().sendBroadcastNotification(
                            title: title,
                            body: body,
                            topic: topic,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Recent Incoming Orders Live Feed ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  i18n.recentOrders,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(1),
                  child: Text(i18n.isArabic ? 'عرض جميع الطلبات' : 'View All Orders'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
              builder: (context, state) {
                if (state is AdminOrdersLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is AdminOrdersLoaded) {
                  final recent = state.orders.take(3).toList();
                  if (recent.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Text(i18n.noRecentOrders),
                    );
                  }

                  return Column(
                    children: recent.map((order) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(IconlyBold.bag, color: AppColors.primary),
                          ),
                          title: Text(
                            order.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${order.date} • ${order.itemCount} ${i18n.itemsCount}',
                            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${order.total.toStringAsFixed(0)} ${i18n.sar}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildStatusMiniBadge(order.state, i18n),
                            ],
                          ),
                          onTap: () => onOpenOrderDetail(order.id),
                        ),
                      );
                    }).toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMiniBadge(String state, AdminI18n i18n) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade700;
    String label = state;

    switch (state) {
      case 'draft':
      case 'pending_payment':
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = i18n.statusPending;
        break;
      case 'confirmed':
      case 'preparing':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF2563EB);
        label = i18n.statusProcessing;
        break;
      case 'out_delivery':
      case 'out_for_delivery':
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF7C3AED);
        label = i18n.statusOutForDelivery;
        break;
      case 'delivered':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        label = i18n.statusDelivered;
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = i18n.statusCancelled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMiniStatBox({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


