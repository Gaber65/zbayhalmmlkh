import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/orders/domain/entities/branch_entity.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_branches_cubit.dart';
import '../widgets/branch_form_dialog.dart';

class AdminBranchesView extends StatefulWidget {
  const AdminBranchesView({super.key});

  @override
  State<AdminBranchesView> createState() => _AdminBranchesViewState();
}

class _AdminBranchesViewState extends State<AdminBranchesView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'active', 'inactive'

  @override
  void initState() {
    super.initState();
    if (context.read<AdminBranchesCubit>().state is AdminBranchesInitial) {
      context.read<AdminBranchesCubit>().loadBranches();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BranchEntity> _filterBranches(List<BranchEntity> branches) {
    return branches.where((b) {
      if (_statusFilter == 'active' && !b.isActive) return false;
      if (_statusFilter == 'inactive' && b.isActive) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = b.name.toLowerCase().contains(q);
        final matchesCity = b.city.toLowerCase().contains(q);
        final matchesAddress = b.address.toLowerCase().contains(q);
        final matchesCode = (b.code ?? '').toLowerCase().contains(q);
        return matchesName || matchesCity || matchesAddress || matchesCode;
      }
      return true;
    }).toList();
  }

  void _openBranchDialog([BranchEntity? branch]) {
    final cubit = context.read<AdminBranchesCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BranchFormDialog(
        branch: branch,
        onSave: (payload) async {
          if (branch == null) {
            return await cubit.createBranch(payload);
          } else {
            return await cubit.updateBranch(branch.id, payload);
          }
        },
      ),
    );
  }

  void _confirmDeleteBranch(BranchEntity branch) {
    final i18n = AdminI18n.of(context);
    final cubit = context.read<AdminBranchesCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(IconlyBold.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(i18n.isArabic ? 'تأكيد حذف الفرع' : 'Confirm Delete'),
          ],
        ),
        content: Text(
          i18n.isArabic
              ? 'هل أنت متأكد من رغبتك في حذف فرع "${branch.name}"؟'
              : 'Are you sure you want to delete branch "${branch.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await cubit.deleteBranch(branch.id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      i18n.isArabic ? 'تم حذف الفرع بنجاح' : 'Branch deleted successfully',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(i18n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          i18n.isArabic ? 'إدارة الفروع ونقاط الاستلام' : 'Branches Management',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
        actions: [
          IconButton(
            tooltip: i18n.isArabic ? 'إضافة فرع' : 'Add Branch',
            icon: const Icon(IconlyLight.plus, color: AppColors.primary),
            onPressed: () => _openBranchDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBranchDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(
          i18n.isArabic ? 'إضافة فرع جديد' : 'New Branch',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<AdminBranchesCubit, AdminBranchesState>(
        listener: (context, state) {
          if (state is AdminBranchesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminBranchesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminBranchesLoaded) {
            final filtered = _filterBranches(state.branches);
            final activeCount = state.branches.where((b) => b.isActive).length;

            return RefreshIndicator(
              onRefresh: () => context.read<AdminBranchesCubit>().loadBranches(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats & Overview Bar
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          title: i18n.isArabic ? 'إجمالي الفروع' : 'Total Branches',
                          value: '${state.branches.length}',
                          icon: IconlyBold.location,
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          title: i18n.isArabic ? 'الفروع النشطة' : 'Active Branches',
                          value: '$activeCount',
                          icon: IconlyBold.tick_square,
                          color: Colors.green,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: i18n.isArabic ? 'بحث بالاسم، المدينة، العنوان...' : 'Search by name, city, address...',
                      prefixIcon: const Icon(IconlyLight.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: i18n.isArabic ? 'الكل (${state.branches.length})' : 'All (${state.branches.length})',
                          value: 'all',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: i18n.isArabic ? 'نشط ($activeCount)' : 'Active ($activeCount)',
                          value: 'active',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: i18n.isArabic
                              ? 'غير نشط (${state.branches.length - activeCount})'
                              : 'Inactive (${state.branches.length - activeCount})',
                          value: 'inactive',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Empty State or List
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(IconlyLight.location, size: 64, color: isDark ? Colors.white30 : Colors.black26),
                          const SizedBox(height: 16),
                          Text(
                            i18n.isArabic ? 'لا توجد فروع مطابقة' : 'No matching branches found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            i18n.isArabic
                                ? 'جرّب البحث بكلمة أخرى أو أضف فرعاً جديداً'
                                : 'Try another query or create a new branch',
                            style: TextStyle(color: isDark ? Colors.white38 : Colors.black45),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((b) => _buildBranchCard(b, isDark, i18n)),
                ],
              ),
            );
          }

          // Fallback / Initial
          return Center(
            child: ElevatedButton.icon(
              onPressed: () => context.read<AdminBranchesCubit>().loadBranches(),
              icon: const Icon(Icons.refresh),
              label: Text(i18n.isArabic ? 'تحميل الفروع' : 'Load Branches'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildBranchCard(BranchEntity branch, bool isDark, AdminI18n i18n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name, Code & Active Badge
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          branch.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (branch.code != null && branch.code!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            branch.code!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: branch.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    branch.isActive ? (i18n.isArabic ? 'نشط' : 'Active') : (i18n.isArabic ? 'غير نشط' : 'Inactive'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: branch.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // City & Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(IconlyLight.location, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${branch.city} - ${branch.address}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Phone and Hours
            Row(
              children: [
                if (branch.phone != null && branch.phone!.isNotEmpty) ...[
                  const Icon(IconlyLight.call, size: 15, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    branch.phone!,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  const SizedBox(width: 16),
                ],
                if (branch.openingHours != null && branch.openingHours!.isNotEmpty) ...[
                  const Icon(IconlyLight.time_circle, size: 15, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      branch.openingHours!,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const Divider(height: 20),

            // Actions row: Edit & Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _confirmDeleteBranch(branch),
                  icon: const Icon(IconlyLight.delete, size: 16, color: Colors.red),
                  label: Text(
                    i18n.delete,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openBranchDialog(branch),
                  icon: const Icon(IconlyLight.edit, size: 16),
                  label: Text(i18n.edit, style: const TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
