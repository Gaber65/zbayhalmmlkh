import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_users_cubit.dart';
import '../widgets/customer_form_dialog.dart';
import '../widgets/customer_detail_dialog.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _scrollController.addListener(_onScroll);
    if (context.read<AdminUsersCubit>().state is AdminUsersInitial) {
      context.read<AdminUsersCubit>().loadUsers();
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminUsersCubit>().loadMoreUsers();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Open Create / Edit Dialog ──────────────────────────────────────────────
  void _openCustomerDialog([AdminUserEntity? user]) {
    final i18n = AdminI18n.of(context);

    showDialog(
      context: context,
      builder: (_) => CustomerFormDialog(
        user: user,
        onSave: (data) async {
          final cubit = context.read<AdminUsersCubit>();
          bool success;
          if (user != null) {
            success = await cubit.updateCustomer(user.id, data);
          } else {
            success = await cubit.createCustomer(data);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  user != null
                      ? (i18n.isArabic
                          ? 'تم تحديث بيانات العميل بنجاح'
                          : 'Customer updated successfully')
                      : (i18n.isArabic
                          ? 'تم إنشاء حساب العميل بنجاح'
                          : 'Customer created successfully'),
                ),
                backgroundColor:
                    success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  // ── Delete / Deactivate Confirmation Dialog ────────────────────────────────
  void _confirmDeleteUser(AdminUserEntity user) {
    final i18n = AdminI18n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(IconlyBold.delete, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                i18n.isArabic ? 'تعطيل / حذف حساب العميل' : 'Delete / Deactivate Customer',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              i18n.isArabic
                  ? 'هل أنت متأكد من رغبتك في تعطيل هذا الحساب؟ سيتم إيقاف دخول العميل مع الحفاظ على سجل الطلبات والمعاملات المالية.'
                  : 'Are you sure you want to deactivate this account? The customer will not be able to log in, but orders and transaction records will be preserved.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              final success =
                  await context.read<AdminUsersCubit>().deleteCustomer(user.id);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (i18n.isArabic
                              ? 'تم تعطيل حساب العميل بنجاح'
                              : 'Customer account deactivated successfully')
                          : (i18n.isArabic
                              ? 'فشل في تعطيل الحساب'
                              : 'Failed to deactivate customer'),
                    ),
                    backgroundColor:
                        success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              i18n.delete,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loyalty Points Adjustment Dialog ──────────────────────────────────────
  void _openLoyaltyAdjustDialog(AdminUserEntity user) {
    final i18n = AdminI18n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pointsController = TextEditingController();
    final reasonController =
        TextEditingController(text: i18n.isArabic ? 'تسوية يدوية من لوحة الإدارة' : 'Manual admin adjustment');
    bool isAdding = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final pointsVal = int.tryParse(pointsController.text.trim()) ?? 0;
          final previewBalance = isAdding
              ? (user.loyaltyPoints + pointsVal)
              : (user.loyaltyPoints - pointsVal).clamp(0, 9999999);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(IconlyBold.star, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    i18n.adjustPoints,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i18n.isArabic ? 'العميل' : 'Customer'}: ${user.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${i18n.currentBalance}: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${user.loyaltyPoints} ${i18n.isArabic ? 'نقطة' : 'pts'}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Center(
                            child: Text(i18n.addPoints),
                          ),
                          selected: isAdding,
                          selectedColor: const Color(0xFF10B981),
                          labelStyle: TextStyle(
                            color: isAdding
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setDialogState(() => isAdding = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Center(
                            child: Text(i18n.deductPoints),
                          ),
                          selected: !isAdding,
                          selectedColor: const Color(0xFFEF4444),
                          labelStyle: TextStyle(
                            color: !isAdding
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setDialogState(() => isAdding = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: pointsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: i18n.pointsCount,
                      prefixIcon: const Icon(IconlyLight.star, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: i18n.reasonLabel,
                      prefixIcon: const Icon(IconlyLight.document, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          i18n.isArabic ? 'الرصيد بعد العملية:' : 'Balance After:',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$previewBalance ${i18n.isArabic ? 'نقطة' : 'pts'}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(i18n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final points = int.tryParse(pointsController.text.trim()) ?? 0;
                  if (points <= 0) return;
                  final effectiveChange = isAdding ? points : -points;
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.of(ctx).pop();
                  final success = await context.read<AdminUsersCubit>().adjustLoyaltyPoints(
                        userId: user.id,
                        pointsChange: effectiveChange,
                        reason: reasonController.text.trim(),
                      );
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? i18n.pointsAdjustSuccess
                              : (i18n.isArabic ? 'فشل في تسوية النقاط' : 'Failed to adjust points'),
                        ),
                        backgroundColor:
                            success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(i18n.save, style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Open Full Customer ERP Detail Dialog ───────────────────────────────────
  void _showUserDetailSheet(AdminUserEntity user) async {
    final i18n = AdminI18n.of(context);

    // Fetch freshest detail from repository to load orders & loyalty transactions
    final result = await context.read<AdminUsersCubit>().repository.getAdminUserDetail(user.id);
    final fullUser = result.fold((failure) => user, (detailedUser) => detailedUser);

    if (!mounted) return;

    CustomerDetailDialog.show(
      context,
      user: fullUser,
      onAdjustPoints: () => _openLoyaltyAdjustDialog(fullUser),
      onEdit: () {
        Navigator.of(context).pop();
        _openCustomerDialog(fullUser);
      },
      onToggleStatus: (activate) async {
        Navigator.of(context).pop();
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final success = await context
            .read<AdminUsersCubit>()
            .toggleCustomerStatus(fullUser.id, activate);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? (activate ? i18n.accountActivated : i18n.accountSuspended)
                    : (i18n.isArabic ? 'فشل تعديل حالة الحساب' : 'Failed to update account status'),
              ),
              backgroundColor:
                  activate ? const Color(0xFF10B981) : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
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

  Widget _buildUserTypeBadge(String type, AdminI18n i18n) {
    final isBusiness = type == 'business';
    final isAdmin = type == 'admin';
    final color = isAdmin ? const Color(0xFF8B5CF6) : (isBusiness ? const Color(0xFF3B82F6) : Colors.grey);
    final label = isAdmin
        ? 'Admin'
        : (isBusiness ? (i18n.isArabic ? 'شركة' : 'Business') : (i18n.isArabic ? 'فردي' : 'Individual'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── KPI Summary Cards ──────────────────────────────────────────────────────
  Widget _buildKPISummary(List<AdminUserEntity> users, bool isDark, AdminI18n i18n) {
    final totalUsers = users.length;
    final activeUsers = users.where((u) => u.status == 'active').length;
    final suspendedUsers = users.where((u) => u.status != 'active').length;
    final totalSales = users.fold<double>(0.0, (acc, u) => acc + u.totalSpending);
    final totalPoints = users.fold<int>(0, (acc, u) => acc + u.loyaltyPoints);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _buildKPICard(
            title: i18n.isArabic ? 'إجمالي العملاء' : 'Total Customers',
            value: '$totalUsers',
            icon: IconlyBold.profile,
            color: AppColors.primary,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _buildKPICard(
            title: i18n.activeUsers,
            value: '$activeUsers',
            icon: Icons.verified_user_rounded,
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _buildKPICard(
            title: i18n.suspendedUsers,
            value: '$suspendedUsers',
            icon: Icons.block_rounded,
            color: const Color(0xFFEF4444),
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _buildKPICard(
            title: i18n.isArabic ? 'إجمالي المشتريات' : 'Total Revenue',
            value: '${totalSales.toStringAsFixed(0)} ${i18n.sar}',
            icon: IconlyBold.wallet,
            color: const Color(0xFF3B82F6),
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _buildKPICard(
            title: i18n.isArabic ? 'نقاط الولاء الممنوحة' : 'Total Loyalty Points',
            value: '$totalPoints',
            icon: IconlyBold.star,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab Item with Badge ────────────────────────────────────────────────────
  Widget _buildTabItem(String label, int count, IconData icon) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Filter helper for active tab ───────────────────────────────────────────
  List<AdminUserEntity> _filterUsers(List<AdminUserEntity> users, int tabIndex) {
    var list = users;

    // Apply Tab Filter
    switch (tabIndex) {
      case 1: // Active
        list = list.where((u) => u.status == 'active').toList();
        break;
      case 2: // Suspended
        list = list.where((u) => u.status != 'active').toList();
        break;
      case 3: // Business
        list = list.where((u) => u.userType == 'business').toList();
        break;
      case 4: // Top Spenders / VIP (sorted by spending desc)
        list = List.from(list)..sort((a, b) => b.totalSpending.compareTo(a.totalSpending));
        list = list.where((u) => u.totalSpending > 0 || u.totalOrdersCount > 0).toList();
        break;
      default: // All
        break;
    }

    // Apply Search Query
    if (_searchQuery.isNotEmpty) {
      list = list.where((u) {
        final matchesName = u.name.toLowerCase().contains(_searchQuery);
        final matchesEmail = u.email.toLowerCase().contains(_searchQuery);
        final matchesPhone = u.phone?.toLowerCase().contains(_searchQuery) ?? false;
        return matchesName || matchesEmail || matchesPhone;
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return BlocBuilder<AdminUsersCubit, AdminUsersState>(
      builder: (context, state) {
        final allUsers = state is AdminUsersLoaded ? state.users : <AdminUserEntity>[];
        final activeCount = allUsers.where((u) => u.status == 'active').length;
        final suspendedCount = allUsers.where((u) => u.status != 'active').length;
        final businessCount = allUsers.where((u) => u.userType == 'business').length;
        final vipCount = allUsers.where((u) => u.totalSpending > 0 || u.totalOrdersCount > 0).length;
        final isLoadingMore = state is AdminUsersLoaded && state.isLoadingMore;

        final currentList = _filterUsers(allUsers, _tabController.index);

        return Column(
          children: [
            // ── Top Search & Quick Action Row ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E24) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                          context.read<AdminUsersCubit>().loadUsers(query: val.trim(), silent: true);
                        },
                        decoration: InputDecoration(
                          hintText: i18n.searchUsersHint,
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          prefixIcon: const Icon(IconlyLight.search, color: AppColors.primary, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                    context.read<AdminUsersCubit>().loadUsers(query: '', silent: true);
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _openCustomerDialog(),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: Colors.white),
                    label: Text(
                      i18n.isArabic ? 'إضافة عميل' : 'Add Customer',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),

            // ── KPI Summary Cards ──────────────────────────────────────────
            if (allUsers.isNotEmpty) _buildKPISummary(allUsers, isDark, i18n),

            // ── Tabs Bar ───────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E24) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: [
                  _buildTabItem(i18n.isArabic ? 'الكل' : 'All', allUsers.length, IconlyLight.profile),
                  _buildTabItem(i18n.isArabic ? 'نشط' : 'Active', activeCount, Icons.check_circle_outline),
                  _buildTabItem(i18n.isArabic ? 'معلق' : 'Suspended', suspendedCount, Icons.block),
                  _buildTabItem(i18n.isArabic ? 'شركات' : 'Business', businessCount, Icons.business),
                  _buildTabItem(i18n.isArabic ? 'كبار العملاء' : 'VIP', vipCount, IconlyLight.star),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ── Users List ─────────────────────────────────────────────────
            Expanded(
              child: state is AdminUsersLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : state is AdminUsersError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 12),
                              Text(state.message),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context.read<AdminUsersCubit>().loadUsers(),
                                child: Text(i18n.isArabic ? 'إعادة المحاولة' : 'Retry'),
                              ),
                            ],
                          ),
                        )
                      : currentList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    IconlyLight.profile,
                                    size: 56,
                                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    i18n.isArabic
                                        ? 'لا يوجد عملاء مطابقين للبحث أو التصفية'
                                        : 'No customers found for this filter',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () => _openCustomerDialog(),
                                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                                    label: Text(i18n.isArabic ? 'إضافة عميل جديد' : 'Add New Customer'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => context.read<AdminUsersCubit>().loadUsers(silent: true),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                itemCount: currentList.length + (isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= currentList.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final user = currentList[index];
                                  final isActive = user.status == 'active';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.black.withValues(alpha: 0.06),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => _showUserDetailSheet(user),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ── Top Row: Avatar + Info + Switch ──────
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // Avatar with Status Ring
                                                Stack(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 24,
                                                      backgroundColor: AppColors.primaryContainer,
                                                      child: Text(
                                                        user.name.isNotEmpty
                                                            ? user.name[0].toUpperCase()
                                                            : 'U',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                          color: AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: Container(
                                                        width: 12,
                                                        height: 12,
                                                        decoration: BoxDecoration(
                                                          color: isActive
                                                            ? const Color(0xFF10B981)
                                                            : const Color(0xFFEF4444),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: isDark
                                                                ? const Color(0xFF1E1E24)
                                                                : Colors.white,
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 12),

                                                // Customer Name + Badges + Phone
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
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 15,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 6),
                                                          _buildUserTypeBadge(user.userType, i18n),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 3),
                                                      if (user.phone != null && user.phone!.isNotEmpty)
                                                        InkWell(
                                                          onTap: () => _callPhone(user.phone!),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                IconlyLight.call,
                                                                size: 13,
                                                                color: AppColors.primary,
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                user.phone!,
                                                                style: const TextStyle(
                                                                  color: AppColors.primary,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      else
                                                        Text(
                                                          user.email,
                                                          style: TextStyle(
                                                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                                                            fontSize: 12,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                    ],
                                                  ),
                                                ),

                                                // Active Switch
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Switch.adaptive(
                                                      value: isActive,
                                                      activeTrackColor: const Color(0xFF10B981),
                                                      activeThumbColor: Colors.white,
                                                      onChanged: (val) async {
                                                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                                                        final success = await context
                                                            .read<AdminUsersCubit>()
                                                            .toggleCustomerStatus(user.id, val);
                                                        if (mounted) {
                                                          scaffoldMessenger.showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                success
                                                                    ? (val
                                                                        ? i18n.accountActivated
                                                                        : i18n.accountSuspended)
                                                                    : (i18n.isArabic
                                                                        ? 'فشل تحديث حالة الحساب'
                                                                        : 'Failed to update status'),
                                                              ),
                                                              backgroundColor: val
                                                                  ? const Color(0xFF10B981)
                                                                  : Colors.red,
                                                              behavior: SnackBarBehavior.floating,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    Text(
                                                      isActive ? i18n.statusActive : i18n.statusSuspended,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: isActive
                                                            ? const Color(0xFF10B981)
                                                            : const Color(0xFFEF4444),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 12),
                                            const Divider(height: 1),
                                            const SizedBox(height: 10),

                                            // ── Metrics Row ──────────────────────────
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? Colors.white.withValues(alpha: 0.04)
                                                          : Colors.grey.shade50,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          IconlyLight.bag,
                                                          size: 14,
                                                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${user.totalOrdersCount} ${i18n.isArabic ? 'طلبات' : 'orders'}',
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(IconlyLight.wallet, size: 14, color: Color(0xFF10B981)),
                                                        const SizedBox(width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            '${user.totalSpending.toStringAsFixed(0)} ${i18n.sar}',
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF10B981),
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryContainer,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(IconlyBold.star, size: 14, color: AppColors.primary),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${user.loyaltyPoints} ${i18n.isArabic ? 'نقطة' : 'pts'}',
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),

                                            // ── Action Buttons Row ───────────────────
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                // Adjust Loyalty Points
                                                TextButton.icon(
                                                  onPressed: () => _openLoyaltyAdjustDialog(user),
                                                  icon: const Icon(IconlyBold.star, size: 15, color: AppColors.primary),
                                                  label: Text(
                                                    i18n.adjustPoints,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    minimumSize: Size.zero,
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),

                                                // View Detail Sheet
                                                TextButton.icon(
                                                  onPressed: () => _showUserDetailSheet(user),
                                                  icon: Icon(
                                                    IconlyLight.show,
                                                    size: 15,
                                                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                                                  ),
                                                  label: Text(
                                                    i18n.isArabic ? 'الملف' : 'Profile',
                                                    style: TextStyle(
                                                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    minimumSize: Size.zero,
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),

                                                // Edit Customer
                                                IconButton(
                                                  icon: const Icon(IconlyLight.edit, size: 16, color: Color(0xFF3B82F6)),
                                                  tooltip: i18n.edit,
                                                  onPressed: () => _openCustomerDialog(user),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                                const SizedBox(width: 10),

                                                // Delete / Deactivate Customer
                                                IconButton(
                                                  icon: const Icon(IconlyLight.delete, size: 16, color: Colors.red),
                                                  tooltip: i18n.delete,
                                                  onPressed: () => _confirmDeleteUser(user),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        );
      },
    );
  }
}
