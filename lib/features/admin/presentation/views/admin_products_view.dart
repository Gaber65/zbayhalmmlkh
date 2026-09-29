import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/catalog/domain/entities/category.dart';
import '../../../user/catalog/domain/entities/product.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_categories_cubit.dart';
import '../manager/admin_options_cubit.dart';
import '../manager/admin_products_cubit.dart';
import '../widgets/product_form_dialog.dart';

class AdminProductsView extends StatefulWidget {
  const AdminProductsView({super.key});

  @override
  State<AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<AdminProductsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (context.read<AdminProductsCubit>().state is AdminProductsInitial) {
      context.read<AdminProductsCubit>().loadProducts();
    }
    if (context.read<AdminCategoriesCubit>().state is AdminCategoriesInitial) {
      context.read<AdminCategoriesCubit>().loadCategories();
    }
    if (context.read<AdminOptionsCubit>().state is AdminOptionsInitial) {
      context.read<AdminOptionsCubit>().loadOptions();
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminProductsCubit>().loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openProductDialog([Product? product]) {
    final catsState = context.read<AdminCategoriesCubit>().state;
    final categories = catsState is AdminCategoriesLoaded ? catsState.categories : <Category>[];
    final i18n = AdminI18n.of(context);

    showDialog(
      context: context,
      builder: (_) => ProductFormDialog(
        product: product,
        categories: categories,
        onSave: (data) async {
          final cubit = context.read<AdminProductsCubit>();
          bool success;
          if (product != null) {
            success = await cubit.updateProduct(product.id, data);
          } else {
            success = await cubit.createProduct(data);
          }

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  product != null
                      ? (i18n.isArabic ? 'تم تحديث بيانات المنتج ومزامنته مع Odoo' : 'Product updated & synced with Odoo')
                      : (i18n.isArabic ? 'تمت إضافة المنتج بنجاح إلى المتجر' : 'Product added successfully'),
                ),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          } else if (!success && mounted) {
            final errorState = cubit.state;
            String errorMsg = i18n.isArabic ? 'فشل في حفظ المنتج، يرجى مراجعة الحقول المطلوبة' : 'Failed to save product, please check required fields';
            if (errorState is AdminProductsError) {
              errorMsg = errorState.message;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _showQuickStockDialog(Product product) {
    final i18n = AdminI18n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: product.stockQuantity?.toInt().toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                i18n.quickStockUpdate,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: i18n.isArabic ? 'الكمية الجديدة بالمخزون' : 'New Stock Quantity',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              final newStock = double.tryParse(controller.text);
              if (newStock != null) {
                Navigator.of(ctx).pop();
                final success = await context.read<AdminProductsCubit>().updateStockQuantity(product.id, newStock);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(i18n.isArabic ? 'تم تحديث المخزون بنجاح' : 'Stock updated successfully'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(i18n.save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    final i18n = AdminI18n.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(i18n.deleteConfirmTitle),
        content: Text(i18n.isArabic ? 'هل أنت متأكد من رغبتك في حذف "${product.title}" نهائياً من قاعدة بيانات Odoo؟' : 'Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await context.read<AdminProductsCubit>().deleteProduct(product.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(i18n.deleteSuccess), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        // ── Top Search & Filter Bar ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E24) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => context.read<AdminProductsCubit>().search(val),
                    decoration: InputDecoration(
                      hintText: i18n.searchProductsHint,
                      hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                      prefixIcon: const Icon(IconlyLight.search, color: AppColors.primary, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context.read<AdminProductsCubit>().search('');
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
                onPressed: () => _openProductDialog(),
                icon: const Icon(IconlyLight.plus, size: 18, color: Colors.white),
                label: Text(
                  i18n.isArabic ? 'إضافة منتج' : 'Add',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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

        // ── ERP Quick Filter Tabs Bar ────────────────────────────────────────
        BlocBuilder<AdminProductsCubit, AdminProductsState>(
          builder: (context, state) {
            final activeFilter = state is AdminProductsLoaded ? state.activeFilter : 'all';
            final selectedCatId = state is AdminProductsLoaded ? state.selectedCategoryId : null;
            final catsState = context.watch<AdminCategoriesCubit>().state;
            final categories = catsState is AdminCategoriesLoaded ? catsState.categories : <Category>[];

            return Container(
              height: 44,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(
                    label: i18n.filterAll,
                    icon: Icons.apps_rounded,
                    isSelected: activeFilter == 'all' && selectedCatId == null,
                    isDark: isDark,
                    onTap: () {
                      context.read<AdminProductsCubit>().setCategoryFilter(null);
                      context.read<AdminProductsCubit>().setFilter('all');
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: i18n.onOffer,
                    isSelected: activeFilter == 'on_offer',
                    isDark: isDark,
                    onTap: () => context.read<AdminProductsCubit>().setFilter('on_offer'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: i18n.lowStockLabel,
                    isSelected: activeFilter == 'low_stock',
                    isDark: isDark,
                    onTap: () => context.read<AdminProductsCubit>().setFilter('low_stock'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: i18n.featured,
                    isSelected: activeFilter == 'featured',
                    isDark: isDark,
                    onTap: () => context.read<AdminProductsCubit>().setFilter('featured'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: i18n.bestSeller,
                    isSelected: activeFilter == 'best_seller',
                    isDark: isDark,
                    onTap: () => context.read<AdminProductsCubit>().setFilter('best_seller'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: i18n.statusActive,
                    isSelected: activeFilter == 'active',
                    isDark: isDark,
                    onTap: () => context.read<AdminProductsCubit>().setFilter('active'),
                  ),

                  // Category Chips
                  if (categories.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                    ...categories.map((c) {
                      final isSelected = selectedCatId == c.id;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildFilterChip(
                          label: c.name,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () {
                            if (isSelected) {
                              context.read<AdminProductsCubit>().setCategoryFilter(null);
                            } else {
                              context.read<AdminProductsCubit>().setCategoryFilter(c.id);
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        ),

        const Divider(height: 1),

        // ── Products List ────────────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<AdminProductsCubit, AdminProductsState>(
            builder: (context, state) {
              if (state is AdminProductsLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (state is AdminProductsError) {
                return Center(child: Text(state.message));
              }

              if (state is AdminProductsLoaded) {
                final products = state.products;

                if (products.isEmpty) {
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
                          child: const Icon(IconlyLight.work, size: 48, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          i18n.isArabic ? 'لم يتم العثور على أي منتجات مطابقة' : 'No matching products found',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openProductDialog(),
                          icon: const Icon(IconlyLight.plus, size: 16, color: Colors.white),
                          label: Text(i18n.addProduct, style: const TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<AdminProductsCubit>().loadProducts(silent: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: products.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= products.length) {
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
                      final product = products[index];
                      return _buildProductCard(context, product, isDark, i18n);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  // ── Rich ERP Product Card ──────────────────────────────────────────────────
  Widget _buildProductCard(BuildContext context, Product product, bool isDark, AdminI18n i18n) {
    final isLowStock = product.isLowStock;
    final profit = product.calculatedProfit;
    final profitPct = product.calculatedProfitPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLowStock
              ? Colors.orange.withValues(alpha: 0.5)
              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
          width: isLowStock ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Image, Details & Action Switches
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Thumbnail with Badge Overlays
                Stack(
                  children: [
                    _buildProductThumbnail(product, isDark),
                    if (product.isOnOffer)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            i18n.isArabic ? 'عرض' : 'SALE',
                            style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if (product.isFeatured)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star, size: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.isBestSeller)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                i18n.isArabic ? 'الأكثر مبيعاً' : 'Hot',
                                style: const TextStyle(color: Colors.deepOrange, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Category & SKU Row
                      Row(
                        children: [
                          if (product.categoryName != null && product.categoryName!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                product.categoryName!,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : AppColors.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (product.sku != null && product.sku!.isNotEmpty)
                            Text(
                              'SKU: ${product.sku}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Price & Profit Row
                      Row(
                        children: [
                          Text(
                            '${product.price} ${i18n.sar}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          if (product.isOnOffer && product.originalPrice != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${product.originalPrice} ${i18n.sar}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (profit > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${profit.toStringAsFixed(1)} ${i18n.sar} (${profitPct.toStringAsFixed(0)}%)',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Active Switch
                Column(
                  children: [
                    Switch(
                      value: product.active,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        context.read<AdminProductsCubit>().toggleAvailability(product.id, val);
                      },
                    ),
                    Text(
                      product.active ? i18n.statusActive : i18n.statusSuspended,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: product.active ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Row 2: Stock Indicator & Action Buttons
            Row(
              children: [
                // Stock Counter & Alert Pill
                InkWell(
                  onTap: () => _showQuickStockDialog(product),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? Colors.orange.withValues(alpha: 0.15)
                          : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F7)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLowStock ? Colors.orange.withValues(alpha: 0.4) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                          size: 14,
                          color: isLowStock ? Colors.orange : (isDark ? Colors.white70 : AppColors.secondary),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isLowStock
                              ? '${i18n.lowStockLabel}: ${product.stockQuantity?.toInt() ?? 0} ${i18n.stockUnits}'
                              : '${i18n.available}: ${product.stockQuantity?.toInt() ?? 0} ${i18n.stockUnits}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isLowStock ? Colors.orange : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 11, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Edit Button
                IconButton(
                  icon: const Icon(IconlyLight.edit, size: 18, color: Color(0xFF3B82F6)),
                  tooltip: i18n.edit,
                  onPressed: () => _openProductDialog(product),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                const SizedBox(width: 6),

                // Delete Button
                IconButton(
                  icon: const Icon(IconlyLight.delete, size: 18, color: Colors.red),
                  tooltip: i18n.delete,
                  onPressed: () => _confirmDelete(product),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(Product product, bool isDark) {
    final imgUrl = product.imageUrl.trim();
    Widget imageWidget;

    if (imgUrl.isEmpty) {
      imageWidget = const Center(
        child: Icon(IconlyLight.work, color: Colors.grey, size: 28),
      );
    } else if (imgUrl.startsWith('data:image')) {
      try {
        final base64String = imgUrl.split(',').last;
        imageWidget = Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(IconlyLight.image, color: Colors.grey, size: 28),
        );
      } catch (_) {
        imageWidget = const Icon(IconlyLight.image, color: Colors.grey, size: 28);
      }
    } else {
      String resolvedUrl = imgUrl;
      if (!resolvedUrl.startsWith('http') && !resolvedUrl.startsWith('//')) {
        final base = AppConfig.baseUrl.endsWith('/')
            ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
            : AppConfig.baseUrl;
        final path = resolvedUrl.startsWith('/') ? resolvedUrl : '/$resolvedUrl';
        resolvedUrl = '$base$path';
      }

      imageWidget = Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (_, error, stackTrace) => Container(
          color: isDark ? const Color(0xFF141418) : Colors.grey.shade100,
          child: const Center(
            child: Icon(IconlyLight.image, color: Colors.grey, size: 28),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 82,
        height: 82,
        color: isDark ? const Color(0xFF141418) : Colors.grey.shade100,
        child: imageWidget,
      ),
    );
  }
}
