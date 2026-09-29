import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';

class CustomerDetailDialog extends StatefulWidget {
  final AdminUserEntity user;
  final VoidCallback onAdjustPoints;
  final VoidCallback onEdit;
  final Future<void> Function(bool activate) onToggleStatus;

  const CustomerDetailDialog({
    super.key,
    required this.user,
    required this.onAdjustPoints,
    required this.onEdit,
    required this.onToggleStatus,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminUserEntity user,
    required VoidCallback onAdjustPoints,
    required VoidCallback onEdit,
    required Future<void> Function(bool activate) onToggleStatus,
  }) {
    final isLargeScreen = MediaQuery.of(context).size.width > 700;
    if (isLargeScreen) {
      return showDialog(
        context: context,
        builder: (_) => CustomerDetailDialog(
          user: user,
          onAdjustPoints: onAdjustPoints,
          onEdit: onEdit,
          onToggleStatus: onToggleStatus,
        ),
      );
    } else {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CustomerDetailDialog(
          user: user,
          onAdjustPoints: onAdjustPoints,
          onEdit: onEdit,
          onToggleStatus: onToggleStatus,
        ),
      );
    }
  }

  @override
  State<CustomerDetailDialog> createState() => _CustomerDetailDialogState();
}

class _CustomerDetailDialogState extends State<CustomerDetailDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _ordersFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Clipboard.setData(ClipboardData(text: clean));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم نسخ رقم الهاتف للحافظة')),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: clean));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ رقم الهاتف للحافظة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);
    final user = widget.user;
    final isActive = user.status == 'active';
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    final content = Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: isLargeScreen
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header Area ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Column(
              children: [
                if (!isLargeScreen)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(isActive, i18n),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user.phone != null && user.phone!.isNotEmpty)
                            InkWell(
                              onTap: () => _callPhone(user.phone!),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(IconlyLight.call, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.phone!,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Quick Action Icons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(IconlyLight.edit, size: 18, color: Color(0xFF3B82F6)),
                          tooltip: i18n.edit,
                          onPressed: widget.onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tabs Bar matching Odoo Notebook ──────────────────────────────
          Container(
            color: isDark ? const Color(0xFF22222A) : const Color(0xFFF9FAFB),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(IconlyLight.chart, size: 16),
                  text: i18n.isArabic ? 'نظرة عامة' : 'Overview',
                ),
                Tab(
                  icon: const Icon(IconlyLight.profile, size: 16),
                  text: i18n.isArabic ? 'المعلومات الشخصية' : 'Personal Info',
                ),
                Tab(
                  icon: const Icon(IconlyLight.star, size: 16),
                  text: i18n.isArabic ? 'محفظة الولاء' : 'Loyalty Wallet',
                ),
                Tab(
                  icon: const Icon(IconlyLight.location, size: 16),
                  text: i18n.savedAddresses,
                ),
                Tab(
                  icon: const Icon(IconlyLight.bag, size: 16),
                  text: i18n.isArabic ? 'الطلبات' : 'Orders',
                ),
              ],
            ),
          ),

          // ── Tab View Content ──────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(user, isDark, i18n),
                _buildPersonalInfoTab(user, isDark, i18n),
                _buildLoyaltyWalletTab(user, isDark, i18n),
                _buildAddressesTab(user, isDark, i18n),
                _buildOrdersTab(user, isDark, i18n),
              ],
            ),
          ),

          // ── Bottom Action Bar ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onAdjustPoints,
                    icon: const Icon(IconlyLight.star, size: 16),
                    label: Text(i18n.adjustPoints),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onToggleStatus(!isActive),
                    icon: Icon(
                      isActive ? IconlyLight.lock : IconlyLight.unlock,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      isActive ? i18n.suspendAccount : i18n.activateAccount,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.red : const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isLargeScreen) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: SizedBox(
          width: 800,
          height: 650,
          child: content,
        ),
      );
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: content,
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 1: Overview
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildOverviewTab(AdminUserEntity user, bool isDark, AdminI18n i18n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Information
          _buildSectionHeader(i18n.isArabic ? 'المعلومات المالية' : 'Financial Information', IconlyBold.wallet),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDetailCard(
                title: i18n.isArabic ? 'إجمالي الطلبات' : 'Total Orders',
                value: '${user.totalOrdersCount}',
                color: const Color(0xFF3B82F6),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildDetailCard(
                title: i18n.totalSpent,
                value: '${user.totalSpending.toStringAsFixed(2)} ${i18n.sar}',
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDetailCard(
                title: i18n.isArabic ? 'متوسط قيمة الطلب' : 'Average Order Value',
                value: '${user.averageOrderValue.toStringAsFixed(2)} ${i18n.sar}',
                color: const Color(0xFF6366F1),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildDetailCard(
                title: i18n.isArabic ? 'إجمالي المستردات' : 'Total Refunds',
                value: '${user.totalRefunds.toStringAsFixed(2)} ${i18n.sar}',
                color: const Color(0xFFEF4444),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Loyalty Summary
          _buildSectionHeader(i18n.isArabic ? 'محفظة نقاط الولاء' : 'Loyalty Wallet', IconlyBold.star),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDetailCard(
                title: i18n.isArabic ? 'الرصيد الحالي' : 'Current Balance',
                value: '${user.loyaltyPoints}',
                color: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildDetailCard(
                title: i18n.isArabic ? 'إجمالي المكتسبة' : 'Total Earned',
                value: '${user.totalEarnedPoints > 0 ? user.totalEarnedPoints : user.loyaltyPoints}',
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildDetailCard(
                title: i18n.isArabic ? 'إجمالي المستبدلة' : 'Total Redeemed',
                value: '${user.totalRedeemedPoints}',
                color: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Activity & Dates
          _buildSectionHeader(i18n.isArabic ? 'سجل الأنشطة والتواريخ' : 'Activity Dates', Icons.access_time_filled_rounded),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF22222A) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  i18n.isArabic ? 'تاريخ التسجيل' : 'Registration Date',
                  user.createDate != null ? user.createDate!.split('T').first : '-',
                  isDark,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  i18n.isArabic ? 'آخر تسجيل دخول' : 'Last Login',
                  user.lastLogin != null ? user.lastLogin!.replaceAll('T', ' ').split('.').first : (i18n.isArabic ? 'غير متوفر' : 'N/A'),
                  isDark,
                ),
                const Divider(height: 16),
                _buildInfoRow(
                  i18n.isArabic ? 'تاريخ آخر نشاط' : 'Last Activity Date',
                  user.lastActivityDate != null ? user.lastActivityDate!.replaceAll('T', ' ').split('.').first : (i18n.isArabic ? 'غير متوفر' : 'N/A'),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 2: Personal Information
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPersonalInfoTab(AdminUserEntity user, bool isDark, AdminI18n i18n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF22222A) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              i18n.isArabic ? 'نوع الحساب (User Type)' : 'User Type',
              user.userType == 'admin'
                  ? 'Admin'
                  : (user.userType == 'business' ? (i18n.isArabic ? 'شركات' : 'Business') : (i18n.isArabic ? 'أفراد' : 'Individual')),
              isDark,
            ),
            const Divider(height: 20),
            _buildInfoRow(
              i18n.isArabic ? 'حالة الحساب (Status)' : 'Status',
              user.status == 'active' ? i18n.statusActive : i18n.statusSuspended,
              isDark,
            ),
            const Divider(height: 20),
            _buildInfoRow(
              i18n.isArabic ? 'اكتمال الملف الشخصي' : 'Profile Completed',
              user.profileCompleted ? (i18n.isArabic ? 'نعم مكتمل' : 'Yes') : (i18n.isArabic ? 'غير مكتمل' : 'No'),
              isDark,
            ),
            const Divider(height: 20),
            _buildInfoRow(
              i18n.isArabic ? 'تاريخ التوثيق (Verified At)' : 'Verified At',
              user.verifiedAt != null ? user.verifiedAt!.replaceAll('T', ' ').split('.').first : (i18n.isArabic ? 'غير موثق' : 'Unverified'),
              isDark,
            ),
            const Divider(height: 20),
            _buildInfoRow(
              i18n.isArabic ? 'الرصيد المالي للحساب' : 'Account Balance',
              '${user.balance.toStringAsFixed(2)} ${user.currency}',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 3: Loyalty Wallet & History
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLoyaltyWalletTab(AdminUserEntity user, bool isDark, AdminI18n i18n) {
    final txs = user.loyaltyTransactions;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildDetailCard(
                title: i18n.isArabic ? 'الرصيد الحالي' : 'Current Balance',
                value: '${user.loyaltyPoints}',
                color: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildDetailCard(
                title: i18n.isArabic ? 'إجمالي المكتسب' : 'Total Earned',
                value: '${user.totalEarnedPoints > 0 ? user.totalEarnedPoints : user.loyaltyPoints}',
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildDetailCard(
                title: i18n.isArabic ? 'إجمالي المستبدل' : 'Total Redeemed',
                value: '${user.totalRedeemedPoints}',
                color: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Icon(IconlyBold.document, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                i18n.isArabic ? 'سجل حركات نقاط الولاء' : 'Loyalty Transaction History',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: txs.isEmpty
              ? Center(
                  child: Text(
                    i18n.isArabic ? 'لا توجد حركات ولاء مسجلة' : 'No loyalty transactions found',
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: txs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final type = tx['transaction_type']?.toString() ?? 'earn';
                    final points = (tx['points'] as num?)?.toInt() ?? 0;
                    final balanceAfter = tx['balance_after'];
                    final date = tx['date']?.toString().replaceAll('T', ' ').split('.').first ?? '';
                    final desc = tx['description']?.toString() ?? '';
                    final orderName = tx['order_name']?.toString();

                    final isEarn = type == 'earn';
                    final isRefund = type.contains('refund');
                    final badgeColor = isEarn
                        ? const Color(0xFF10B981)
                        : (isRefund ? const Color(0xFFEF4444) : const Color(0xFF3B82F6));
                    final badgeText = isEarn
                        ? (i18n.isArabic ? 'مكتسبة' : 'Earned')
                        : (isRefund
                            ? (i18n.isArabic ? 'تعديل استرجاع' : 'Refund Adj.')
                            : (i18n.isArabic ? 'تسوية يدوية' : 'Manual Adj.'));

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF22222A) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (orderName != null && orderName.isNotEmpty)
                                  Text(
                                    orderName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                Text(
                                  desc.isNotEmpty ? desc : date,
                                  style: const TextStyle(fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${points > 0 ? '+' : ''}$points',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: points >= 0 ? const Color(0xFF10B981) : Colors.red,
                                ),
                              ),
                              if (balanceAfter != null)
                                Text(
                                  '${i18n.isArabic ? 'الرصيد:' : 'Bal:'} $balanceAfter',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 4: Addresses
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildAddressesTab(AdminUserEntity user, bool isDark, AdminI18n i18n) {
    final addresses = user.addresses;

    if (addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconlyLight.location, size: 48, color: isDark ? Colors.white24 : Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              i18n.noAddresses,
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final addr = addresses[index];
        final title = addr['title']?.toString() ?? (i18n.isArabic ? 'العنوان' : 'Address');
        final recipient = addr['recipient_name']?.toString() ?? '';
        final phone = addr['recipient_phone']?.toString() ?? '';
        final city = addr['city']?.toString() ?? '';
        final street = addr['street']?.toString() ?? '';
        final country = addr['country']?.toString() ?? '';
        final lat = addr['latitude'];
        final lng = addr['longitude'];
        final isDefault = addr['is_default'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDark ? const Color(0xFF22222A) : const Color(0xFFF9FAFB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(IconlyBold.location, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          i18n.isArabic ? 'العنوان الافتراضي' : 'Default',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$city${city.isNotEmpty && street.isNotEmpty ? ' - ' : ''}$street${country.isNotEmpty ? ' ($country)' : ''}',
                  style: const TextStyle(fontSize: 13),
                ),
                if (recipient.isNotEmpty || phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (recipient.isNotEmpty) ...[
                        Icon(IconlyLight.profile, size: 13, color: isDark ? Colors.white60 : Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(recipient, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade700)),
                        const SizedBox(width: 14),
                      ],
                      if (phone.isNotEmpty) ...[
                        Icon(IconlyLight.call, size: 13, color: isDark ? Colors.white60 : Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(phone, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade700)),
                      ],
                    ],
                  ),
                ],
                if (lat != null && lng != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'GPS: $lat, $lng',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 5: Orders
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildOrdersTab(AdminUserEntity user, bool isDark, AdminI18n i18n) {
    var orders = user.orders;

    if (_ordersFilter != 'all') {
      orders = orders.where((o) => o['state'] == _ordersFilter).toList();
    }

    return Column(
      children: [
        // Sub-filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildOrderFilterChip('all', i18n.isArabic ? 'جميع الطلبات' : 'All', isDark),
              const SizedBox(width: 6),
              _buildOrderFilterChip('delivered', i18n.isArabic ? 'الطلبات المكتملة' : 'Delivered', isDark),
              const SizedBox(width: 6),
              _buildOrderFilterChip('cancelled', i18n.isArabic ? 'الملغاة' : 'Cancelled', isDark),
              const SizedBox(width: 6),
              _buildOrderFilterChip('refunded', i18n.isArabic ? 'المستردة' : 'Refunded', isDark),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Text(
                    i18n.isArabic ? 'لا توجد طلبات مسجلة' : 'No orders found',
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final o = orders[index];
                    final name = o['name']?.toString() ?? '';
                    final date = o['date']?.toString().replaceAll('T', ' ').split('.').first ?? '';
                    final state = o['state']?.toString() ?? 'draft';
                    final paymentStatus = o['payment_status']?.toString() ?? 'pending';
                    final total = (o['total'] as num?)?.toDouble() ?? 0.0;

                    Color stateColor = Colors.blue;
                    if (state == 'delivered') stateColor = const Color(0xFF10B981);
                    if (state == 'cancelled') stateColor = Colors.red;
                    if (state == 'refunded') stateColor = const Color(0xFFEF4444);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF22222A) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: stateColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        state,
                                        style: TextStyle(
                                          color: stateColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  '${i18n.paymentStatus}: $paymentStatus',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${total.toStringAsFixed(2)} ${i18n.sar}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrderFilterChip(String value, String label, bool isDark) {
    final selected = _ordersFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (val) {
        if (val) setState(() => _ordersFilter = value);
      },
    );
  }

  // ── Helper UI Widgets ──────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF22222A) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive, AdminI18n i18n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? i18n.statusActive : i18n.statusSuspended,
        style: TextStyle(
          color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
