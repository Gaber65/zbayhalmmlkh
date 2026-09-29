import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/offers/domain/entities/offer_entity.dart';
import '../../core/admin_i18n.dart';
import 'admin_image_upload_picker.dart';

class OfferFormDialog extends StatefulWidget {
  final OfferEntity? offer;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const OfferFormDialog({
    super.key,
    this.offer,
    required this.onSave,
  });

  @override
  State<OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends State<OfferFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _subtitleController;
  late TextEditingController _descController;
  late TextEditingController _discountValController;
  late TextEditingController _badgeTextController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late String _discountType;
  late bool _isActive;
  String? _base64Image;
  String? _currentImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    _nameController = TextEditingController(text: o?.name ?? '');
    _subtitleController = TextEditingController(text: o?.subtitle ?? '');
    _descController = TextEditingController(text: o?.description ?? '');
    _discountValController = TextEditingController(text: o?.discountValue.toString() ?? '10.0');
    _badgeTextController = TextEditingController(text: o?.badgeText ?? '');
    _startDateController = TextEditingController(text: o?.startDate ?? '');
    _endDateController = TextEditingController(text: o?.endDate ?? '');
    _discountType = o?.discountType ?? 'percentage';
    _isActive = o?.isActive ?? true;
    _currentImageUrl = o?.bannerImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _descController.dispose();
    _discountValController.dispose();
    _badgeTextController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      final payload = <String, dynamic>{
        'name': _nameController.text.trim(),
        if (_subtitleController.text.trim().isNotEmpty) 'subtitle': _subtitleController.text.trim(),
        if (_descController.text.trim().isNotEmpty) 'description': _descController.text.trim(),
        'discount_type': _discountType,
        'discount_value': double.tryParse(_discountValController.text.trim()) ?? 10.0,
        if (_badgeTextController.text.trim().isNotEmpty) 'badge_text': _badgeTextController.text.trim(),
        if (_startDateController.text.trim().isNotEmpty) 'start_date': _startDateController.text.trim(),
        if (_endDateController.text.trim().isNotEmpty) 'end_date': _endDateController.text.trim(),
        'active': _isActive,
        if (_base64Image != null) 'banner_image': _base64Image,
      };

      final success = await widget.onSave(payload);
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
    final isEdit = widget.offer != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(IconlyBold.discount, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit
                          ? (i18n.isArabic ? 'تعديل بيانات العرض الترويجي' : 'Edit Promotional Offer')
                          : (i18n.isArabic ? 'إضافة عرض ترويجي جديد' : 'New Promotional Offer'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner Image Picker
                      AdminImageUploadPicker(
                        label: i18n.isArabic ? 'صورة بنر العرض' : 'Offer Banner Image',
                        initialImageUrl: _currentImageUrl,
                        onImagePicked: ({imagePath, base64Image, imageBytes, fileName}) {
                          _base64Image = base64Image;
                        },
                        onImageRemoved: () {
                          _base64Image = null;
                          _currentImageUrl = null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: i18n.isArabic ? 'عنوان العرض *' : 'Offer Title *',
                          hintText: i18n.isArabic ? 'مثال: عرض نهاية الأسبوع' : 'e.g. Weekend Special',
                          prefixIcon: const Icon(IconlyLight.discount),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return i18n.isArabic ? 'يرجى إدخال عنوان العرض' : 'Offer title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      TextFormField(
                        controller: _subtitleController,
                        decoration: InputDecoration(
                          labelText: i18n.isArabic ? 'العنوان الفرعي' : 'Subtitle',
                          hintText: i18n.isArabic ? 'خصم خاص على الذبائح المختارة' : 'Special discount on fresh meat',
                          prefixIcon: const Icon(IconlyLight.paper),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Discount Type & Value Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _discountType,
                              decoration: InputDecoration(
                                labelText: i18n.isArabic ? 'نوع الخصم' : 'Discount Type',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'percentage',
                                  child: Text(i18n.isArabic ? 'نسبة مئوية (%)' : 'Percentage (%)'),
                                ),
                                DropdownMenuItem(
                                  value: 'fixed',
                                  child: Text(i18n.isArabic ? 'مبلغ ثابت (ر.س)' : 'Fixed Amount (SAR)'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _discountType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _discountValController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: i18n.isArabic ? 'قيمة الخصم *' : 'Discount Value *',
                                hintText: '15',
                                prefixIcon: const Icon(Icons.price_change_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return i18n.isArabic ? 'مطلوب' : 'Required';
                                }
                                if (double.tryParse(v.trim()) == null) {
                                  return i18n.isArabic ? 'رقم غير صحيح' : 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Badge Text
                      TextFormField(
                        controller: _badgeTextController,
                        decoration: InputDecoration(
                          labelText: i18n.isArabic ? 'شارة العرض (Badge)' : 'Offer Badge Text',
                          hintText: i18n.isArabic ? 'خصم 15% أو عرض حصري' : 'e.g. 15% OFF',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dates Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startDateController,
                              decoration: InputDecoration(
                                labelText: i18n.isArabic ? 'تاريخ البدء' : 'Start Date',
                                hintText: 'YYYY-MM-DD',
                                prefixIcon: const Icon(IconlyLight.calendar),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _endDateController,
                              decoration: InputDecoration(
                                labelText: i18n.isArabic ? 'تاريخ الانتهاء' : 'End Date',
                                hintText: 'YYYY-MM-DD',
                                prefixIcon: const Icon(IconlyLight.calendar),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: i18n.isArabic ? 'وصف العرض' : 'Description',
                          hintText: i18n.isArabic ? 'تفاصيل وشروط العرض الترويجي...' : 'Terms and details...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Active Switch
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            i18n.isArabic ? 'تفعيل العرض' : 'Active Offer',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            i18n.isArabic
                                ? 'إظهار العرض في الصفحة الرئيسية ومتجر العملاء'
                                : 'Show offer in storefront and home banner',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                          ),
                          value: _isActive,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: Text(i18n.cancel),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isEdit ? (i18n.isArabic ? 'حفظ التعديلات' : 'Save Changes') : (i18n.isArabic ? 'إضافة العرض' : 'Add Offer'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
