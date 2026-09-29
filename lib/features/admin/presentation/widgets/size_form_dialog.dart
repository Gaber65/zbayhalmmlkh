import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/catalog/domain/entities/product.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';

class SizeFormDialog extends StatefulWidget {
  final AdminSizeEntity? size;
  final List<Product> products;
  final int? preselectedProductId;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const SizeFormDialog({
    super.key,
    this.size,
    required this.products,
    this.preselectedProductId,
    required this.onSave,
  });

  @override
  State<SizeFormDialog> createState() => _SizeFormDialogState();
}

class _SizeFormDialogState extends State<SizeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _subTitleController;
  late TextEditingController _priceController;
  late TextEditingController _caloriesController;
  late TextEditingController _sequenceController;

  int? _selectedProductId;
  bool _isDefault = false;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.size;
    _nameController = TextEditingController(text: s?.name ?? '');
    _subTitleController = TextEditingController(text: s?.subTitle ?? '');
    _priceController = TextEditingController(
      text: s != null ? s.price.toStringAsFixed(2) : '',
    );
    _caloriesController = TextEditingController(
      text: s != null ? '${s.calories}' : '243',
    );
    _sequenceController = TextEditingController(
      text: s != null ? '${s.sequence}' : '10',
    );

    _selectedProductId = s?.productId ?? widget.preselectedProductId ?? (widget.products.isNotEmpty ? widget.products.first.id : null);
    _isDefault = s?.isDefault ?? false;
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subTitleController.dispose();
    _priceController.dispose();
    _caloriesController.dispose();
    _sequenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedProductId == null || _selectedProductId! <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار الذبيحة / المنتج المرتبط بهذا الحجم'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isSaving = true);

      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final calories = int.tryParse(_caloriesController.text.trim()) ?? 243;
      final seq = int.tryParse(_sequenceController.text.trim()) ?? 10;

      final data = <String, dynamic>{
        if (widget.size != null) 'id': widget.size!.id,
        'product_id': _selectedProductId,
        'name': _nameController.text.trim(),
        'sub_title': _subTitleController.text.trim(),
        'price': price,
        'calories': calories,
        'sequence': seq,
        'is_default': _isDefault,
        'active': _isActive,
        'is_active': _isActive,
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
    final isEdit = widget.size != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(IconlyBold.filter_2, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? (i18n.isArabic ? 'تعديل حجم الذبيحة' : 'Edit Carcass Size')
                                : (i18n.isArabic ? 'إضافة حجم ذبيحة جديد' : 'New Carcass Size'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            i18n.isArabic
                                ? 'تحديد الوزن والسعر والسعرات الحرارية لكل حجم'
                                : 'Set weight, price, and calories for this size',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Product Selector
                DropdownButtonFormField<int>(
                  initialValue: _selectedProductId,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'الذبيحة / المنتج *' : 'Product *',
                    prefixIcon: const Icon(IconlyLight.bag),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: widget.products.map((p) {
                    return DropdownMenuItem<int>(
                      value: p.id,
                      child: Text(p.title, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedProductId = val);
                  },
                  validator: (v) => v == null ? (i18n.isArabic ? 'اختر المنتج' : 'Select product') : null,
                ),
                const SizedBox(height: 16),

                // Size Name (e.g. جذع، هرفي، وسط)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'اسم الحجم (مثال: هرفي / جذع وسط) *' : 'Size Name *',
                    prefixIcon: const Icon(IconlyLight.bookmark),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? (i18n.isArabic ? 'اسم الحجم مطلوب' : 'Size name is required')
                      : null,
                ),
                const SizedBox(height: 16),

                // Subtitle / Note (e.g. يجزئ عقيقة)
                TextFormField(
                  controller: _subTitleController,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'وصف مختصر / ملاحظة (مثال: يجزئ عقيقة)' : 'Subtitle / Note',
                    prefixIcon: const Icon(IconlyLight.info_circle),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Price & Calories
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: i18n.isArabic ? 'السعر (ر.س) *' : 'Price (SAR) *',
                          prefixIcon: const Icon(IconlyLight.wallet),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return i18n.isArabic ? 'السعر مطلوب' : 'Price required';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return i18n.isArabic ? 'سعر غير صالح' : 'Invalid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: i18n.isArabic ? 'السعرات الحرارية' : 'Calories',
                          prefixIcon: const Icon(Icons.local_fire_department_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sequence
                TextFormField(
                  controller: _sequenceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'الترتيب في العرض' : 'Display Sequence',
                    prefixIcon: const Icon(Icons.sort),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Switches (Default & Active)
                SwitchListTile(
                  title: Text(i18n.isArabic ? 'الحجم الافتراضي للذبيحة' : 'Default Carcass Size'),
                  subtitle: Text(
                    i18n.isArabic
                        ? 'يتم اختياره تلقائياً عند فتح صفحة تفاصيل الذبيحة'
                        : 'Pre-selected when customer views the product',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _isDefault,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isDefault = v),
                ),
                SwitchListTile(
                  title: Text(i18n.isArabic ? 'الحجم نشط ومتاح للطلب' : 'Active and Available'),
                  value: _isActive,
                  activeTrackColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(i18n.cancel),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSaving ? null : _submit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check, size: 20),
                      label: Text(
                        _isSaving
                            ? (i18n.isArabic ? 'جاري الحفظ...' : 'Saving...')
                            : (isEdit ? i18n.saveChanges : (i18n.isArabic ? 'إضافة الحجم' : 'Add Size')),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
