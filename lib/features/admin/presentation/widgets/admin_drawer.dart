import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/app_cubit/app_cubit.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../core/admin_i18n.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectIndex;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              20,
            ),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF1F1F23), Color(0xFF18181B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.dashboard_customize_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            i18n.isArabic ? 'ذبائح المملكة' : 'Dhabayih Al-Mamlaka',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            i18n.erpMenu,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Color(0xFF4ADE80), size: 8),
                      const SizedBox(width: 6),
                      Text(
                        i18n.liveServer,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              children: [
                _buildMenuItem(
                  context: context,
                  index: 0,
                  icon: IconlyBold.category,
                  title: i18n.menuDashboard,
                  subtitle: i18n.isArabic ? 'نظرة عامة على المبيعات والـ KPIs' : 'Sales overview & KPIs',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(0);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  index: 1,
                  icon: IconlyBold.bag,
                  title: i18n.menuOrders,
                  subtitle: i18n.isArabic ? 'متابعة وتحديث حالات الطلبات' : 'Track and update order status',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(1);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  index: 2,
                  icon: Icons.inventory_2_rounded,
                  title: i18n.menuProducts,
                  subtitle: i18n.isArabic ? 'الأسعار، العروض، والكميات' : 'Prices, offers, and quantities',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(2);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  index: 3,
                  icon: IconlyBold.folder,
                  title: i18n.menuCategories,
                  subtitle: i18n.isArabic ? 'التقطيع، التغليف، والأقسام' : 'Cuts, packaging, and sections',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(3);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  index: 4,
                  icon: IconlyBold.profile,
                  title: i18n.menuUsers,
                  subtitle: i18n.isArabic ? 'سجل المستخدمين ونقاط الولاء' : 'Customer profiles & loyalty points',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(4);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  index: 5,
                  icon: Icons.payment_rounded,
                  title: i18n.menuPayments,
                  subtitle: i18n.isArabic ? 'سجل الدفع وحركات الولاء' : 'Payment records & loyalty log',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(5);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  index: 6,
                  icon: IconlyBold.discount,
                  title: i18n.menuMarketing,
                  subtitle: i18n.isArabic ? 'الكوبونات، البانرات، والقصص' : 'Coupons, banners, and stories',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(6);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  index: 7,
                  icon: Icons.store_mall_directory_rounded,
                  title: i18n.isArabic ? 'الفروع ونقاط الاستلام' : 'Branches & Pickups',
                  subtitle: i18n.isArabic ? 'إدارة المستودعات، المدن، والتفعيل' : 'Manage warehouses, cities & status',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(7);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  index: 8,
                  icon: Icons.settings_rounded,
                  title: i18n.menuSettings,
                  subtitle: i18n.isArabic ? 'برنامج الولاء والواتساب والتواصل' : 'Loyalty rates & WhatsApp contact',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectIndex(8);
                  },
                ),
              ],
            ),
          ),

          // ── App Settings & Preferences Section (Moved from AppBar) ──────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F24) : const Color(0xFFF7F7F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 15, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      i18n.isArabic ? 'تفضيلات التطبيق' : 'Preferences',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 1. Language Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      i18n.isArabic ? 'اللغة' : 'Language',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141418) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildSegmentButton(
                            title: 'عربي',
                            isSelected: i18n.isArabic,
                            isDark: isDark,
                            onTap: () => context.read<AppCubit>().changeLanguage('ar'),
                          ),
                          _buildSegmentButton(
                            title: 'English',
                            isSelected: !i18n.isArabic,
                            isDark: isDark,
                            onTap: () => context.read<AppCubit>().changeLanguage('en'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. Theme Mode Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      i18n.isArabic ? 'المظهر' : 'Theme',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141418) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildSegmentButton(
                            title: i18n.isArabic ? "فاتح" : "Light",
                            isSelected: !isDark,
                            isDark: isDark,
                            onTap: () => context.read<AppCubit>().changeTheme(ThemeMode.light),
                          ),
                          _buildSegmentButton(
                            title: i18n.isArabic ? "داكن" : "Dark",
                            isSelected: isDark,
                            isDark: isDark,
                            onTap: () => context.read<AppCubit>().changeTheme(ThemeMode.dark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(Routes.home);
                    },
                    icon: const Icon(Icons.storefront, size: 18),
                    label: Text(
                      i18n.backToStore,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryContainer)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F7)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.secondary),
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white : AppColors.onSurface),
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ),
    );
  }
}
