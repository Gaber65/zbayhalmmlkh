import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/catalog/domain/entities/category.dart';
import '../../../user/catalog/domain/entities/product.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_options_cubit.dart';
import 'admin_image_upload_picker.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final List<Category> categories;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.categories,
    required this.onSave,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _titleEnController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _weightController;
  late TextEditingController _prepTimeController;

  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _discountValueController;
  late TextEditingController _offerPriceController;

  late TextEditingController _stockController;
  late TextEditingController _minimumStockController;
  late TextEditingController _loyaltyPointsController;

  String? _base64Image;
  String? _currentImageUrl;
  int? _selectedCategoryId;

  bool _active = true;
  bool _isFeatured = false;
  bool _isBestSeller = false;
  bool _isAvailable = true;
  bool _isOnOffer = false;
  String _discountType = 'percentage'; // 'percentage' | 'fixed'
  DateTime? _offerStartDate;
  DateTime? _offerEndDate;

  // Selected Option IDs
  final Set<int> _selectedCuttingIds = {};
  final Set<int> _selectedPackagingIds = {};
  final Set<int> _selectedExcludedIds = {};
  final List<Map<String, dynamic>> _customSizes = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final p = widget.product;
    if (p != null && p.sizes.isNotEmpty) {
      _customSizes.addAll(
        p.sizes.map(
          (s) => {
            'id': s.id,
            'name': s.name,
            'sub_title': s.subTitle,
            'price': s.price,
            'calories': s.calories,
            'is_default': s.isDefault,
            'is_active': true,
          },
        ),
      );
    }

    _titleController = TextEditingController(text: p?.title ?? '');
    _titleEnController = TextEditingController(text: p?.titleEn ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _weightController = TextEditingController(
      text: p?.weightKg != null ? p!.weightKg.toString() : '',
    );
    _prepTimeController = TextEditingController(
      text: p?.preparationTimeMin != null
          ? p!.preparationTimeMin.toString()
          : '',
    );

    _purchasePriceController = TextEditingController(
      text: p?.purchasePrice != null ? p!.purchasePrice.toString() : '',
    );
    _sellingPriceController = TextEditingController(
      text: p?.price != null ? p!.price.toString() : '',
    );
    _discountValueController = TextEditingController(
      text: p?.discountValue != null ? p!.discountValue.toString() : '',
    );
    _offerPriceController = TextEditingController(
      text: p?.offerPrice != null ? p!.offerPrice.toString() : '',
    );

    _stockController = TextEditingController(
      text: p?.stockQuantity != null
          ? p!.stockQuantity!.toInt().toString()
          : '0',
    );
    _minimumStockController = TextEditingController(
      text: p?.minimumStock != null ? p!.minimumStock!.toInt().toString() : '0',
    );
    _loyaltyPointsController = TextEditingController(
      text: p?.loyaltyPoints != null ? p!.loyaltyPoints.toString() : '0',
    );

    _currentImageUrl = p?.imageUrl;
    _selectedCategoryId =
        p?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
    _active = p?.active ?? true;
    _isFeatured = p?.isFeatured ?? false;
    _isBestSeller = p?.isBestSeller ?? false;
    _isAvailable = p?.isAvailable ?? true;
    _isOnOffer = p?.isOnOffer ?? false;
    _discountType = p?.discountType ?? 'percentage';

    if (p?.offerStartDate != null) {
      _offerStartDate = DateTime.tryParse(p!.offerStartDate!);
    }
    if (p?.offerEndDate != null) {
      _offerEndDate = DateTime.tryParse(p!.offerEndDate!);
    }

    if (p != null) {
      _selectedCuttingIds.addAll(p.cuttingOptions.map((o) => o.id));
      _selectedPackagingIds.addAll(p.packagingOptions.map((o) => o.id));
      _selectedExcludedIds.addAll(p.excludedParts.map((o) => o.id));
    }

    // Auto calculate offer price & profit when prices change
    _sellingPriceController.addListener(_recalcOfferAndProfit);
    _purchasePriceController.addListener(_recalcOfferAndProfit);
    _discountValueController.addListener(_recalcOfferAndProfit);
  }

  void _recalcOfferAndProfit() {
    if (!mounted) return;
    final sell = double.tryParse(_sellingPriceController.text) ?? 0.0;
    final disc = double.tryParse(_discountValueController.text) ?? 0.0;

    if (_isOnOffer && disc > 0) {
      double calcOffer = sell;
      if (_discountType == 'percentage') {
        calcOffer = sell - (sell * disc / 100);
      } else {
        calcOffer = sell - disc;
      }
      if (calcOffer < 0) calcOffer = 0;
      _offerPriceController.text = calcOffer.toStringAsFixed(2);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _titleEnController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _prepTimeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _discountValueController.dispose();
    _offerPriceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    _loyaltyPointsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      final purchasePrice =
          double.tryParse(_purchasePriceController.text) ?? 0.0;
      final sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0.0;
      final discountVal = double.tryParse(_discountValueController.text) ?? 0.0;
      final stock = double.tryParse(_stockController.text) ?? 0.0;
      final minStock = double.tryParse(_minimumStockController.text) ?? 0.0;
      final weight = double.tryParse(_weightController.text);
      final prepTime = double.tryParse(_prepTimeController.text);

      // Auto generate SKU if empty
      String sku = _skuController.text.trim();
      if (sku.isEmpty) {
        sku =
            'PROD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      }

      final data = <String, dynamic>{
        'name': _titleController.text.trim(),
        'sku': sku.toUpperCase().replaceAll(' ', '-'),
        'barcode': _barcodeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'purchase_price': purchasePrice > 0
            ? purchasePrice
            : sellingPrice * 0.7,
        'selling_price': sellingPrice,
        'discount_type': _discountType,
        'discount_value': discountVal,
        if (_offerStartDate != null)
          'offer_start_date': _offerStartDate!
              .toIso8601String()
              .split('T')
              .first,
        if (_offerEndDate != null)
          'offer_end_date': _offerEndDate!.toIso8601String().split('T').first,
        'stock_quantity': stock,
        'minimum_stock': minStock,
        'weight': ?weight,
        'preparation_time': ?prepTime,
        'active': _active,
        'is_featured': _isFeatured,
        'is_best_seller': _isBestSeller,
        if (_base64Image != null && _base64Image!.isNotEmpty)
          'main_image': _base64Image,
        if (_selectedCategoryId != null && _selectedCategoryId! > 0)
          'category_id': _selectedCategoryId,
        'cutting_option_ids': _selectedCuttingIds.toList(),
        'packaging_ids': _selectedPackagingIds.toList(),
        'excluded_part_ids': _selectedExcludedIds.toList(),
        if (_customSizes.isNotEmpty) 'sizes': _customSizes,
      };

      final success = await widget.onSave(data);
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    // Calculate live margins
    final purchase = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0.0;
    final effectiveSell =
        (_isOnOffer && (double.tryParse(_offerPriceController.text) ?? 0) > 0)
        ? double.parse(_offerPriceController.text)
        : selling;
    final profitVal = effectiveSell - purchase;
    final profitPct = purchase > 0 ? (profitVal / purchase) * 100 : 0.0;

    return BlocProvider(
      create: (_) => getIt<AdminOptionsCubit>()..loadOptions(),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 820),
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        IconlyBold.work,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? (i18n.isArabic
                                      ? 'تعديل المنتج (${widget.product!.title})'
                                      : 'Edit Product')
                                : i18n.addProduct,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            i18n.isArabic
                                ? 'ربط المواصفات، المخزون، والأسعار مع Odoo ERP'
                                : 'Sync specifications, stock & prices with Odoo ERP',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.secondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // ── Modern Tab Bar ───────────────────────────────────────────
              Container(
                color: isDark
                    ? const Color(0xFF18181D)
                    : const Color(0xFFF9F9FB),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark
                      ? Colors.white60
                      : Colors.black54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  tabs: [
                    Tab(
                      icon: const Icon(IconlyLight.document, size: 16),
                      text: i18n.tabBasicInfo,
                    ),
                    Tab(
                      icon: const Icon(IconlyLight.wallet, size: 16),
                      text: i18n.tabPricing,
                    ),
                    Tab(
                      icon: const Icon(Icons.line_weight_rounded, size: 16),
                      text: i18n.isArabic ? 'أحجام الذبيحة' : 'Carcass Sizes',
                    ),
                    Tab(
                      icon: const Icon(IconlyLight.work, size: 16),
                      text: i18n.tabInventory,
                    ),
                    Tab(
                      icon: const Icon(IconlyLight.image, size: 16),
                      text: i18n.tabMedia,
                    ),
                  ],
                ),
              ),

              // ── Form Content ─────────────────────────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Basic Information
                      _buildBasicInfoTab(isDark, i18n),

                      // Tab 2: Pricing, Profit & Offers
                      _buildPricingTab(isDark, i18n, profitVal, profitPct),

                      // Tab 3: Carcass Sizes
                      _buildSizesTab(isDark, i18n),

                      // Tab 4: Stock & Options
                      _buildStockAndOptionsTab(isDark, i18n),

                      // Tab 5: Media
                      _buildMediaTab(isDark, i18n),
                    ],
                  ),
                ),
              ),

              // ── Footer ───────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(i18n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEdit ? i18n.save : i18n.addProduct,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Basic Information ───────────────────────────────────────────────
  Widget _buildBasicInfoTab(bool isDark, AdminI18n i18n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Arabic
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText:
                  '${i18n.isArabic ? "اسم المنتج بالعربية" : "Product Name (AR)"} *',
              hintText: i18n.isArabic
                  ? 'مثال: ريش ضأن بلدي'
                  : 'e.g. Local Lamb Chops',
              prefixIcon: const Icon(IconlyLight.document, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? i18n.fieldRequired : null,
          ),
          const SizedBox(height: 14),

          // Name English
          TextFormField(
            controller: _titleEnController,
            decoration: InputDecoration(
              labelText: i18n.isArabic
                  ? 'اسم المنتج بالإنجليزية (اختياري)'
                  : 'Product Name (EN)',
              hintText: 'e.g. Fresh Lamb Chops',
              prefixIcon: const Icon(IconlyLight.document, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Category Selector
          if (widget.categories.isNotEmpty) ...[
            DropdownButtonFormField<int>(
              initialValue: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: '${i18n.categoryName} *',
                prefixIcon: const Icon(IconlyLight.category, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: widget.categories.map((c) {
                return DropdownMenuItem<int>(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
            const SizedBox(height: 14),
          ],

          // SKU & Barcode Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _skuController,
                  decoration: InputDecoration(
                    labelText: i18n.skuLabel,
                    hintText: 'e.g. LAMB-001',
                    prefixIcon: const Icon(IconlyLight.ticket, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: i18n.barcodeLabel,
                    hintText: 'e.g. 6281000123',
                    prefixIcon: const Icon(Icons.qr_code, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Weight & Preparation Time
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: i18n.weightLabel,
                    hintText: '1.5',
                    prefixIcon: const Icon(Icons.scale_rounded, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _prepTimeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: i18n.prepTimeLabel,
                    hintText: '25',
                    prefixIcon: const Icon(IconlyLight.time_circle, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Full Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: i18n.isArabic
                  ? 'وصف المنتج وتفاصيل الذبح'
                  : 'Description',
              prefixIcon: const Icon(IconlyLight.paper, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Badges & Flags Switches
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141418) : const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    i18n.isArabic
                        ? 'تفعيل المنتج في المتجر (Active)'
                        : 'Active in Store',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  value: _active,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (val) => setState(() => _active = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    i18n.isArabic
                        ? 'تمييز كمنتج مميز (Featured)'
                        : 'Featured Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  value: _isFeatured,
                  activeThumbColor: Colors.amber,
                  onChanged: (val) => setState(() => _isFeatured = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    i18n.isArabic
                        ? 'شارة الأكثر مبيعاً (Best Seller)'
                        : 'Best Seller',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  value: _isBestSeller,
                  activeThumbColor: Colors.deepOrange,
                  onChanged: (val) => setState(() => _isBestSeller = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Pricing, Profit & Offers ────────────────────────────────────────
  Widget _buildPricingTab(
    bool isDark,
    AdminI18n i18n,
    double profitVal,
    double profitPct,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purchase Price & Selling Price
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _purchasePriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${i18n.purchasePriceLabel} (${i18n.sar}) *',
                    hintText: '40.0',
                    prefixIcon: const Icon(IconlyLight.wallet, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? i18n.fieldRequired
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _sellingPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${i18n.price} (${i18n.sar}) *',
                    hintText: '65.0',
                    prefixIcon: const Icon(
                      IconlyLight.buy,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? i18n.fieldRequired
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Realtime Profit Margin Cards
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: profitVal >= 0
                  ? Colors.green.withValues(alpha: isDark ? 0.15 : 0.08)
                  : Colors.red.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: profitVal >= 0
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  profitVal >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: profitVal >= 0 ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i18n.isArabic
                            ? 'حاسبة هامش الربح التلقائي'
                            : 'Real-time Profit Margin',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${i18n.profitMarginLabel}: ${profitVal.toStringAsFixed(2)} ${i18n.sar}  •  ${i18n.profitPercentageLabel}: ${profitPct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: profitVal >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Offers Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141418) : const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text(
                    i18n.isArabic
                        ? 'تطبيق عرض وتخفيض خاص'
                        : 'Apply Special Discount / Offer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  value: _isOnOffer,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _isOnOffer = val;
                      _recalcOfferAndProfit();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                if (_isOnOffer) ...[
                  const Divider(height: 16),
                  // Discount Type Toggle
                  Row(
                    children: [
                      Text(
                        i18n.isArabic ? 'نوع الخصم:' : 'Discount Type:',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: Text(
                          i18n.isArabic ? 'نسبة مئوية (%)' : 'Percentage (%)',
                        ),
                        selected: _discountType == 'percentage',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _discountType == 'percentage'
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        onSelected: (sel) {
                          if (sel) {
                            setState(() {
                              _discountType = 'percentage';
                              _recalcOfferAndProfit();
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(
                          i18n.isArabic
                              ? 'مبلغ ثابت (ر.س)'
                              : 'Fixed Amount (SAR)',
                        ),
                        selected: _discountType == 'fixed',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _discountType == 'fixed'
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        onSelected: (sel) {
                          if (sel) {
                            setState(() {
                              _discountType = 'fixed';
                              _recalcOfferAndProfit();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Discount Value & Offer Price Result
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _discountValueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _discountType == 'percentage'
                                ? 'قيمة الخصم (%)'
                                : 'قيمة الخصم (${i18n.sar})',
                            hintText: _discountType == 'percentage'
                                ? '10'
                                : '15.0',
                            prefixIcon: const Icon(
                              IconlyLight.discount,
                              size: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _offerPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'السعر النهائي بعد العرض (${i18n.sar})',
                            prefixIcon: const Icon(
                              IconlyBold.discount,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date Range Pickers
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _offerStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _offerStartDate = picked);
                            }
                          },
                          icon: const Icon(IconlyLight.calendar, size: 16),
                          label: Text(
                            _offerStartDate != null
                                ? 'بدء: ${_offerStartDate!.toString().split(" ").first}'
                                : (i18n.isArabic
                                      ? 'تاريخ بدء العرض'
                                      : 'Start Date'),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  _offerEndDate ??
                                  DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _offerEndDate = picked);
                            }
                          },
                          icon: const Icon(IconlyLight.calendar, size: 16),
                          label: Text(
                            _offerEndDate != null
                                ? 'انتهاء: ${_offerEndDate!.toString().split(" ").first}'
                                : (i18n.isArabic
                                      ? 'تاريخ نهاية العرض'
                                      : 'End Date'),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Loyalty points
          TextFormField(
            controller: _loyaltyPointsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: i18n.loyaltyPoints,
              hintText: '10',
              prefixIcon: const Icon(
                IconlyLight.star,
                size: 18,
                color: Colors.amber,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Stock & Options ─────────────────────────────────────────────────
  Widget _buildStockAndOptionsTab(bool isDark, AdminI18n i18n) {
    return BlocBuilder<AdminOptionsCubit, AdminOptionsState>(
      builder: (context, state) {
        final cuttingOptions = state is AdminOptionsLoaded
            ? state.cuttingOptions
            : [];
        final packagingOptions = state is AdminOptionsLoaded
            ? state.packagingOptions
            : [];
        final excludedParts = state is AdminOptionsLoaded
            ? state.excludedParts
            : [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock & Minimum Alert Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            '${i18n.isArabic ? "الكمية المتاحة بالمخزون" : "Stock Quantity"} *',
                        prefixIcon: const Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? i18n.fieldRequired
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minimumStockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: i18n.minStockLabel,
                        prefixIcon: const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.orange,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Availability Toggle
              SwitchListTile(
                title: Text(
                  i18n.isArabic
                      ? 'جاهز للطلب الفوري (In Stock)'
                      : 'Available for immediate orders',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                value: _isAvailable,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) => setState(() => _isAvailable = val),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Cutting Options Multi-Select Chips
              Text(
                i18n.isArabic
                    ? 'خيارات التقطيع المتاحة لهذا المنتج:'
                    : 'Available Cutting Options:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              if (cuttingOptions.isEmpty)
                Text(
                  i18n.isArabic
                      ? 'لا توجد خيارات تقطيع مضافة'
                      : 'No cutting options',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: cuttingOptions.map((opt) {
                    final selected = _selectedCuttingIds.contains(opt.id);
                    return FilterChip(
                      label: Text(opt.name),
                      selected: selected,
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedCuttingIds.add(opt.id);
                          } else {
                            _selectedCuttingIds.remove(opt.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // Packaging Options Multi-Select Chips
              Text(
                i18n.isArabic
                    ? 'خيارات التغليف المتاحة لهذا المنتج:'
                    : 'Available Packaging Options:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              if (packagingOptions.isEmpty)
                Text(
                  i18n.isArabic
                      ? 'لا توجد خيارات تغليف مضافة'
                      : 'No packaging options',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: packagingOptions.map((opt) {
                    final selected = _selectedPackagingIds.contains(opt.id);
                    return FilterChip(
                      label: Text(opt.name),
                      selected: selected,
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedPackagingIds.add(opt.id);
                          } else {
                            _selectedPackagingIds.remove(opt.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // Excluded Parts Multi-Select Chips
              Text(
                i18n.isArabic
                    ? 'الأجزاء المستبعدة المتاحة للاختيار (بدون شحم، بدون جلد...):'
                    : 'Excluded Parts Options:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              if (excludedParts.isEmpty)
                Text(
                  i18n.isArabic
                      ? 'لا توجد أجزاء مستبعدة مضافة'
                      : 'No excluded parts',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: excludedParts.map((opt) {
                    final selected = _selectedExcludedIds.contains(opt.id);
                    return FilterChip(
                      label: Text(opt.name),
                      selected: selected,
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedExcludedIds.add(opt.id);
                          } else {
                            _selectedExcludedIds.remove(opt.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 4: Media & Gallery ─────────────────────────────────────────────────
  Widget _buildMediaTab(bool isDark, AdminI18n i18n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            i18n.isArabic
                ? 'الصورة الرئيسية للمنتج (Main Image)'
                : 'Main Product Image',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          AdminImageUploadPicker(
            initialImageUrl: _currentImageUrl,
            label: i18n.imageUploadLabel,
            onImagePicked: ({imagePath, base64Image, imageBytes, fileName}) {
              setState(() => _base64Image = base64Image);
            },
            onImageRemoved: () {
              setState(() {
                _base64Image = null;
                _currentImageUrl = null;
              });
            },
          ),
          const SizedBox(height: 20),

          // Gallery images note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141418) : const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  IconlyLight.info_square,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    i18n.isArabic
                        ? 'يتم ربط الصور تلقائياً مع خادم Odoo بجودة عالية ودمجها في المعرض المباشر للتطبيق.'
                        : 'Images are automatically synchronized with Odoo server in high resolution.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
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

  // ── Tab 3: Carcass Sizes Tab ────────────────────────────────────────────────
  Widget _buildSizesTab(bool isDark, AdminI18n i18n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner explanation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    i18n.isArabic
                        ? 'يمكنك تحديد أحجام مخصصة للذبيحة (مثل: هرفي، جذع، جبر) مع تسعير وسعرات لكل حجم. يختار العميل الحجم المطلوب مباشرة في التطبيق.'
                        : 'Define custom carcass sizes (e.g. Harfi, Jatha, Jabr) with specific pricing and calories for customer selection.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Header with Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                i18n.isArabic
                    ? 'قائمة أحجام الذبيحة (${_customSizes.length})'
                    : 'Carcass Sizes List (${_customSizes.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddOrEditSizeModal(
                  context: context,
                  isDark: isDark,
                  i18n: i18n,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  i18n.isArabic ? 'إضافة حجم' : 'Add Size',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_customSizes.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.line_weight_rounded,
                    size: 48,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    i18n.isArabic
                        ? 'لم يتم تحديد أحجام مخصصة بعد'
                        : 'No custom carcass sizes defined yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    i18n.isArabic
                        ? 'في حال عدم إضافة أحجام، سيتم استخدام السعر الأساسي المعين في تبويب الأسعار.'
                        : 'If no sizes are added, base selling price will be used for the product.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._customSizes.asMap().entries.map((entry) {
              final idx = entry.key;
              final size = entry.value;
              final isDefault = size['is_default'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF222228) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDefault
                        ? AppColors.primary
                        : (isDark
                              ? Colors.white12
                              : Colors.black.withValues(alpha: 0.08)),
                    width: isDefault ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (isDefault
                                    ? AppColors.primary
                                    : AppColors.secondary)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.scale_rounded,
                        color: isDefault
                            ? AppColors.primary
                            : AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                size['name']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    i18n.isArabic
                                        ? 'الحجم الافتراضي'
                                        : 'Default',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (size['sub_title'] != null &&
                              size['sub_title']
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              size['sub_title'].toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${size['price']} ${i18n.sar}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (size['calories'] != null &&
                                  (size['calories'] is num) &&
                                  (size['calories'] as num) > 0) ...[
                                const SizedBox(width: 12),
                                Text(
                                  '🔥 ${size['calories']} سعرة',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: i18n.isArabic ? 'تعديل' : 'Edit',
                      onPressed: () => _showAddOrEditSizeModal(
                        context: context,
                        isDark: isDark,
                        i18n: i18n,
                        initialSize: size,
                        index: idx,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      tooltip: i18n.isArabic ? 'حذف' : 'Delete',
                      onPressed: () {
                        setState(() {
                          _customSizes.removeAt(idx);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showAddOrEditSizeModal({
    required BuildContext context,
    required bool isDark,
    required AdminI18n i18n,
    Map<String, dynamic>? initialSize,
    int? index,
  }) {
    final nameCtrl = TextEditingController(
      text: initialSize?['name']?.toString() ?? '',
    );
    final subtitleCtrl = TextEditingController(
      text: initialSize?['sub_title']?.toString() ?? '',
    );
    final priceCtrl = TextEditingController(
      text: initialSize?['price']?.toString() ?? '',
    );
    final calCtrl = TextEditingController(
      text: initialSize?['calories']?.toString() ?? '243',
    );
    bool isDef = initialSize?['is_default'] == true;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
          title: Text(
            index != null
                ? (i18n.isArabic ? 'تعديل الحجم' : 'Edit Size')
                : (i18n.isArabic ? 'إضافة حجم للذبيحة' : 'Add Carcass Size'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'اسم الحجم *' : 'Size Name *',
                    hintText: i18n.isArabic
                        ? 'مثال: هرفي، جذع وسط، جبر'
                        : 'e.g. Harfi, Medium',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtitleCtrl,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic
                        ? 'ملاحظة / وصف الحجم'
                        : 'Subtitle / Note',
                    hintText: i18n.isArabic
                        ? 'مثال: يجزئ عقيقة'
                        : 'e.g. Valid for Aqiqah',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: i18n.isArabic
                        ? 'السعر (ر.س) *'
                        : 'Price (SAR) *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: calCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'السعرات الحرارية' : 'Calories',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    i18n.isArabic ? 'الحجم الافتراضي' : 'Default Size',
                  ),
                  value: isDef,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setModalState(() => isDef = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: Text(i18n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text) ?? 0.0;
                if (name.isEmpty || price <= 0) return;

                final item = <String, dynamic>{
                  if (initialSize?['id'] != null) 'id': initialSize!['id'],
                  'name': name,
                  'sub_title': subtitleCtrl.text.trim(),
                  'price': price,
                  'calories': int.tryParse(calCtrl.text) ?? 243,
                  'is_default': isDef,
                  'is_active': true,
                };

                setState(() {
                  if (isDef) {
                    for (var s in _customSizes) {
                      s['is_default'] = false;
                    }
                  }
                  if (index != null) {
                    _customSizes[index] = item;
                  } else {
                    _customSizes.add(item);
                  }
                });

                Navigator.of(dCtx).pop();
              },
              child: Text(i18n.save),
            ),
          ],
        ),
      ),
    );
  }
}
