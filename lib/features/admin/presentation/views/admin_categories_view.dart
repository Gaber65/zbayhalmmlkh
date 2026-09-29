import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/catalog/domain/entities/category.dart';
import '../../../user/catalog/domain/entities/product.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_categories_cubit.dart';
import '../manager/admin_options_cubit.dart';
import '../manager/admin_products_cubit.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/option_form_dialog.dart';
import '../widgets/size_form_dialog.dart';

class AdminCategoriesView extends StatefulWidget {
  const AdminCategoriesView({super.key});

  @override
  State<AdminCategoriesView> createState() => _AdminCategoriesViewState();
}

class _AdminCategoriesViewState extends State<AdminCategoriesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _optionFilter = 'all'; // 'all', 'active', 'with_fee', 'free'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    if (context.read<AdminCategoriesCubit>().state is AdminCategoriesInitial) {
      context.read<AdminCategoriesCubit>().loadCategories();
    }
    if (context.read<AdminOptionsCubit>().state is AdminOptionsInitial) {
      context.read<AdminOptionsCubit>().loadOptions();
    }
    if (context.read<AdminProductsCubit>().state is AdminProductsInitial) {
      context.read<AdminProductsCubit>().loadProducts();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openCategoryDialog([Category? cat]) {
    final i18n = AdminI18n.of(context);

    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(
        category: cat,
        onSave: (data) async {
          final cubit = context.read<AdminCategoriesCubit>();
          bool success;
          if (cat != null) {
            success = await cubit.updateCategory(cat.id, data);
          } else {
            success = await cubit.createCategory(data);
          }
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(cat != null
                    ? (i18n.isArabic ? 'تم تحديث بيانات القسم بنجاح' : 'Category updated successfully')
                    : (i18n.isArabic ? 'تمت إضافة القسم بنجاح' : 'Category added successfully')),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (!success && mounted) {
            final errorState = cubit.state;
            String errorMsg = i18n.isArabic
                ? 'فشل في حفظ القسم، يرجى المحاولة مرة أخرى'
                : 'Failed to save category, please try again';
            if (errorState is AdminCategoriesError) {
              errorMsg = errorState.message;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _openOptionDialog(String defaultType, [AdminOptionEntity? opt]) {
    final i18n = AdminI18n.of(context);

    showDialog(
      context: context,
      builder: (_) => OptionFormDialog(
        option: opt,
        defaultType: defaultType,
        onSave: (data) async {
          final success = await context.read<AdminOptionsCubit>().saveOption(data);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(i18n.saveSuccess),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _confirmDeleteCategory(Category cat) {
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
                i18n.deleteConfirmTitle,
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
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              i18n.deleteCategoryConfirm,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await context.read<AdminCategoriesCubit>().deleteCategory(cat.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? i18n.deleteSuccess : (i18n.isArabic ? 'فشل حذف القسم' : 'Failed to delete category')),
                    backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(i18n.delete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOption(AdminOptionEntity opt) {
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
                i18n.deleteConfirmTitle,
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
              opt.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              i18n.deleteOptionConfirm,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await context.read<AdminOptionsCubit>().deleteOption(opt.id, type: opt.type);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? i18n.deleteSuccess : (i18n.isArabic ? 'فشل حذف الخيار' : 'Failed to delete option')),
                    backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(i18n.delete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getAddButtonLabel(int index, AdminI18n i18n) {
    switch (index) {
      case 0:
        return i18n.isArabic ? 'إضافة قسم' : 'Add Category';
      case 1:
        return i18n.isArabic ? 'إضافة تقطيع' : 'Add Cut';
      case 2:
        return i18n.isArabic ? 'إضافة تغليف' : 'Add Packaging';
      case 3:
        return i18n.isArabic ? 'إضافة استبعاد' : 'Add Excluded';
      case 4:
        return i18n.isArabic ? 'إضافة حجم ذبيحة' : 'Add Size';
      default:
        return i18n.addCategory;
    }
  }

  void _triggerAdd(int index) {
    switch (index) {
      case 0:
        _openCategoryDialog();
        break;
      case 1:
        _openOptionDialog('cutting');
        break;
      case 2:
        _openOptionDialog('packaging');
        break;
      case 3:
        _openOptionDialog('excluded_part');
        break;
      case 4:
        _openSizeDialog();
        break;
    }
  }

  void _openSizeDialog([AdminSizeEntity? size]) {
    final i18n = AdminI18n.of(context);
    final prodState = context.read<AdminProductsCubit>().state;
    final products = prodState is AdminProductsLoaded ? prodState.products : <Product>[];

    showDialog(
      context: context,
      builder: (_) => SizeFormDialog(
        size: size,
        products: products,
        onSave: (data) async {
          final success = await context.read<AdminOptionsCubit>().saveSize(data);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(i18n.saveSuccess),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _confirmDeleteSize(AdminSizeEntity size) {
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
                i18n.deleteConfirmTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          i18n.isArabic
              ? 'هل أنت متأكد من حذف الحجم "${size.name}"؟'
              : 'Are you sure you want to delete size "${size.name}"?',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await context.read<AdminOptionsCubit>().deleteSize(size.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? i18n.deleteSuccess : (i18n.isArabic ? 'فشل حذف الحجم' : 'Failed to delete size')),
                    backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(i18n.delete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Column(
      children: [
        // ── Top Search & Quick Action Row ────────────────────────────────────
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
                    },
                    decoration: InputDecoration(
                      hintText: i18n.searchCategoriesHint,
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
                onPressed: () => _triggerAdd(_tabController.index),
                icon: const Icon(IconlyLight.plus, size: 18, color: Colors.white),
                label: Text(
                  _getAddButtonLabel(_tabController.index, i18n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),

        // ── Sub-tabs Bar with Dynamic Count Badges ───────────────────────────
        BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
          builder: (context, catState) {
            final catCount = catState is AdminCategoriesLoaded ? catState.categories.length : 0;

            return BlocBuilder<AdminOptionsCubit, AdminOptionsState>(
              builder: (context, optState) {
                final cutCount = optState is AdminOptionsLoaded ? optState.cuttingOptions.length : 0;
                final packCount = optState is AdminOptionsLoaded ? optState.packagingOptions.length : 0;
                final exclCount = optState is AdminOptionsLoaded ? optState.excludedParts.length : 0;
                final sizeCount = optState is AdminOptionsLoaded ? optState.sizes.length : 0;

                return Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark ? Colors.white60 : AppColors.secondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: [
                      Tab(text: '${i18n.tabSubCategories} ($catCount)'),
                      Tab(text: '${i18n.tabSubCuts} ($cutCount)'),
                      Tab(text: '${i18n.tabSubPackaging} ($packCount)'),
                      Tab(text: '${i18n.tabSubExcluded} ($exclCount)'),
                      Tab(text: '${i18n.isArabic ? "أحجام الذبائح" : "Carcass Sizes"} ($sizeCount)'),
                    ],
                  ),
                );
              },
            );
          },
        ),

        const Divider(height: 1),

        // ── Tab Views ────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoriesTab(isDark, i18n),
              _buildOptionsTab('cutting', isDark, i18n),
              _buildOptionsTab('packaging', isDark, i18n),
              _buildOptionsTab('excluded_part', isDark, i18n),
              _buildSizesTab(isDark, i18n),
            ],
          ),
        ),
      ],
    );
  }

  // ── 1. Categories Grid Tab ─────────────────────────────────────────────────
  Widget _buildCategoriesTab(bool isDark, AdminI18n i18n) {
    return BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
      builder: (context, state) {
        if (state is AdminCategoriesLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is AdminCategoriesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(state.message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<AdminCategoriesCubit>().loadCategories(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(i18n.retry, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state is AdminCategoriesLoaded) {
          var cats = state.categories;

          // Filter by search query
          if (_searchQuery.isNotEmpty) {
            cats = cats.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();
          }

          // Products state to calculate count of products in each category
          final productsState = context.watch<AdminProductsCubit>().state;
          final List<Product> allProducts = productsState is AdminProductsLoaded ? productsState.products : [];

          if (cats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E24) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(IconlyLight.category, size: 48, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _searchQuery.isNotEmpty ? i18n.noCategoriesFound : (i18n.isArabic ? 'لا توجد أقسام مضافة حالياً' : 'No categories available'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openCategoryDialog(),
                    icon: const Icon(IconlyLight.plus, size: 16, color: Colors.white),
                    label: Text(i18n.addCategory, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<AdminCategoriesCubit>().loadCategories(silent: true),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final cat = cats[index];
                final prodCount = allProducts.where((p) => p.categoryId == cat.id).length;

                return _buildCategoryCard(context, cat, prodCount, isDark, i18n);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Rich ERP Category Card ─────────────────────────────────────────────────
  Widget _buildCategoryCard(
    BuildContext context,
    Category cat,
    int productCount,
    bool isDark,
    AdminI18n i18n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image / Hero Section with Product Count Badge
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: cat.imageUrl.isNotEmpty
                        ? Image.network(
                            cat.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildCategoryFallbackImage(isDark),
                          )
                        : _buildCategoryFallbackImage(isDark),
                  ),
                ),
                // Products Count Tag Overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '$productCount ${i18n.productsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details & Actions Section
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Edit Button
                      InkWell(
                        onTap: () => _openCategoryDialog(cat),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(IconlyLight.edit, size: 16, color: Color(0xFF3B82F6)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete Button
                      InkWell(
                        onTap: () => _confirmDeleteCategory(cat),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(IconlyLight.delete, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFallbackImage(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF141418) : AppColors.primaryContainer.withValues(alpha: 0.35),
      child: const Center(
        child: Icon(IconlyLight.category, size: 42, color: AppColors.primary),
      ),
    );
  }

  // ── 2. Customization Options Tab (Cutting, Packaging, Excluded Parts) ───────
  Widget _buildOptionsTab(String type, bool isDark, AdminI18n i18n) {
    return BlocBuilder<AdminOptionsCubit, AdminOptionsState>(
      builder: (context, state) {
        if (state is AdminOptionsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is AdminOptionsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(state.message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<AdminOptionsCubit>().loadOptions(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(i18n.retry, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state is AdminOptionsLoaded) {
          List<AdminOptionEntity> options;
          if (type == 'cutting') {
            options = state.cuttingOptions;
          } else if (type == 'packaging') {
            options = state.packagingOptions;
          } else {
            options = state.excludedParts;
          }

          // Search filtering
          if (_searchQuery.isNotEmpty) {
            options = options.where((o) {
              final nameMatch = o.name.toLowerCase().contains(_searchQuery);
              final descMatch = o.description != null && o.description!.toLowerCase().contains(_searchQuery);
              return nameMatch || descMatch;
            }).toList();
          }

          // Quick Filter chips
          if (_optionFilter == 'active') {
            options = options.where((o) => o.isActive).toList();
          } else if (_optionFilter == 'with_fee') {
            options = options.where((o) => o.extraPrice > 0).toList();
          } else if (_optionFilter == 'free') {
            options = options.where((o) => o.extraPrice == 0).toList();
          }

          return Column(
            children: [
              // Quick Filter Chips Bar
              Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip(
                      label: i18n.filterAll,
                      icon: Icons.apps_rounded,
                      isSelected: _optionFilter == 'all',
                      isDark: isDark,
                      onTap: () => setState(() => _optionFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: i18n.statusActive,
                      isSelected: _optionFilter == 'active',
                      isDark: isDark,
                      onTap: () => setState(() => _optionFilter = 'active'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: i18n.filterWithFee,
                      isSelected: _optionFilter == 'with_fee',
                      isDark: isDark,
                      onTap: () => setState(() => _optionFilter = 'with_fee'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: i18n.filterFree,
                      isSelected: _optionFilter == 'free',
                      isDark: isDark,
                      onTap: () => setState(() => _optionFilter = 'free'),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Options List
              Expanded(
                child: options.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E24) : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                type == 'cutting'
                                    ? Icons.content_cut_rounded
                                    : (type == 'packaging' ? Icons.inventory_2_rounded : Icons.do_not_disturb_on_total_silence_rounded),
                                size: 44,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _searchQuery.isNotEmpty ? i18n.noOptionsFound : (i18n.isArabic ? 'لا توجد خيارات مسجلة' : 'No options registered'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _openOptionDialog(type),
                              icon: const Icon(IconlyLight.plus, size: 16, color: Colors.white),
                              label: Text(_getAddButtonLabel(_tabController.index, i18n), style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => context.read<AdminOptionsCubit>().loadOptions(silent: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final opt = options[index];
                            return _buildOptionCard(context, opt, type, isDark, i18n);
                          },
                        ),
                      ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Rich ERP Option Card ───────────────────────────────────────────────────
  Widget _buildOptionCard(
    BuildContext context,
    AdminOptionEntity opt,
    String type,
    bool isDark,
    AdminI18n i18n,
  ) {
    Color iconColor;
    Color iconBgColor;
    IconData optionIcon;

    if (type == 'cutting') {
      iconColor = const Color(0xFFD97706);
      iconBgColor = const Color(0xFFFEF3C7);
      optionIcon = Icons.content_cut_rounded;
    } else if (type == 'packaging') {
      iconColor = const Color(0xFF2563EB);
      iconBgColor = const Color(0xFFDBEAFE);
      optionIcon = Icons.inventory_2_rounded;
    } else {
      iconColor = const Color(0xFFDC2626);
      iconBgColor = const Color(0xFFFEE2E2);
      optionIcon = Icons.do_not_disturb_on_total_silence_rounded;
    }

    if (isDark) {
      iconBgColor = iconColor.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: opt.isActive
              ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06))
              : Colors.grey.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(optionIcon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Name & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: opt.isActive
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.grey,
                        ),
                      ),
                      if (opt.description != null && opt.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          opt.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Price & Status Badges Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (opt.extraPrice > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                '+ ${opt.extraPrice.toStringAsFixed(0)} ${i18n.sar} ${i18n.extraFee}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                i18n.freeOption,
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: opt.isActive
                                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              opt.isActive ? i18n.optionStatusActive : i18n.optionStatusInactive,
                              style: TextStyle(
                                color: opt.isActive ? const Color(0xFF10B981) : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Active Switch
                Column(
                  children: [
                    Switch.adaptive(
                      value: opt.isActive,
                      activeTrackColor: AppColors.primary,
                      onChanged: (_) {
                        context.read<AdminOptionsCubit>().toggleOptionStatus(opt);
                      },
                    ),
                    Text(
                      opt.isActive ? i18n.statusActive : i18n.inactive,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: opt.isActive ? AppColors.primary : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 6),

            // Card Action Buttons Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openOptionDialog(type, opt),
                  icon: const Icon(IconlyLight.edit, size: 16, color: Color(0xFF3B82F6)),
                  label: Text(
                    i18n.edit,
                    style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDeleteOption(opt),
                  icon: const Icon(IconlyLight.delete, size: 16, color: Colors.red),
                  label: Text(
                    i18n.delete,
                    style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E1E24) : const Color(0xFFF4F4F7)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.secondary),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Carcass Sizes Tab (الأحجام وأوزان الذبائح) ───────────────────────────
  Widget _buildSizesTab(bool isDark, AdminI18n i18n) {
    return BlocBuilder<AdminOptionsCubit, AdminOptionsState>(
      builder: (context, state) {
        if (state is AdminOptionsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is AdminOptionsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(state.message, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<AdminOptionsCubit>().loadOptions(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(i18n.retry, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state is AdminOptionsLoaded) {
          var sizes = state.sizes;

          // Search filtering
          if (_searchQuery.isNotEmpty) {
            sizes = sizes.where((s) {
              final nameMatch = s.name.toLowerCase().contains(_searchQuery);
              final prodMatch = s.productName.toLowerCase().contains(_searchQuery);
              final subMatch = s.subTitle != null && s.subTitle!.toLowerCase().contains(_searchQuery);
              return nameMatch || prodMatch || subMatch;
            }).toList();
          }

          if (sizes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.scale_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    i18n.isArabic ? 'لا توجد أحجام مسجلة' : 'No carcass sizes found',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openSizeDialog(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      i18n.isArabic ? 'إضافة حجم جديد' : 'Add New Size',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<AdminOptionsCubit>().loadOptions(silent: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sizes.length,
              itemBuilder: (context, index) {
                final size = sizes[index];
                return _buildSizeCard(context, size, isDark, i18n);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSizeCard(BuildContext context, AdminSizeEntity size, bool isDark, AdminI18n i18n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: size.isDefault
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.scale_rounded,
              color: size.isDefault ? AppColors.primary : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      size.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (size.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          i18n.isArabic ? 'افتراضي' : 'Default',
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
                const SizedBox(height: 4),
                Text(
                  '${size.productName.isNotEmpty ? size.productName : (i18n.isArabic ? "ذبيحة" : "Product")} • ${size.calories} ${i18n.isArabic ? "سعرة" : "cal"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                if (size.subTitle != null && size.subTitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    size.subTitle!,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${size.price.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _openSizeDialog(size),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(IconlyLight.edit, size: 16, color: Color(0xFF3B82F6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _confirmDeleteSize(size),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(IconlyLight.delete, size: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
