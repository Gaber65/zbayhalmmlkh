import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/orders/domain/entities/branch_entity.dart';
import '../../core/admin_i18n.dart';

class BranchFormDialog extends StatefulWidget {
  final BranchEntity? branch;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const BranchFormDialog({
    super.key,
    this.branch,
    required this.onSave,
  });

  @override
  State<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _codeController;
  late TextEditingController _phoneController;
  late TextEditingController _openingHoursController;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.branch;
    _nameController = TextEditingController(text: b?.name ?? '');
    _cityController = TextEditingController(text: b?.city ?? '');
    _addressController = TextEditingController(text: b?.address ?? '');
    _codeController = TextEditingController(text: b?.code ?? '');
    _phoneController = TextEditingController(text: b?.phone ?? '');
    _openingHoursController = TextEditingController(text: b?.openingHours ?? '08:00 AM - 11:00 PM');
    _isActive = b?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _codeController.dispose();
    _phoneController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      final payload = <String, dynamic>{
        'name': _nameController.text.trim(),
        'name_ar': _nameController.text.trim(),
        'city': _cityController.text.trim(),
        'address': _addressController.text.trim(),
        if (_codeController.text.trim().isNotEmpty) 'code': _codeController.text.trim(),
        if (_phoneController.text.trim().isNotEmpty) 'phone': _phoneController.text.trim(),
        if (_openingHoursController.text.trim().isNotEmpty) 'opening_hours': _openingHoursController.text.trim(),
        'active': _isActive,
        'is_active': _isActive,
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
    final isEdit = widget.branch != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
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
                    child: const Icon(IconlyBold.location, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit
                          ? (i18n.isArabic ? 'تعديل الفرع' : 'Edit Branch')
                          : (i18n.isArabic ? 'إضافة فرع جديد' : 'Add New Branch'),
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
                      // Branch Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: i18n.isArabic ? 'اسم الفرع *' : 'Branch Name *',
                          hintText: i18n.isArabic ? 'مثال: فرع الرياض الرئيسي' : 'e.g. Riyadh Main Branch',
                          prefixIcon: const Icon(IconlyLight.location),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return i18n.isArabic ? 'يرجى إدخال اسم الفرع' : 'Branch name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // City and Code Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: i18n.isArabic ? 'المدينة *' : 'City *',
                                hintText: i18n.isArabic ? 'الرياض' : 'Riyadh',
                                prefixIcon: const Icon(Icons.location_city_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return i18n.isArabic ? 'يرجى إدخال المدينة' : 'City is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                labelText: i18n.isArabic ? 'رمز الفرع' : 'Branch Code',
                                hintText: 'RUH-01',
                                prefixIcon: const Icon(Icons.qr_code_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: i18n.isArabic ? 'العنوان التفصيلي *' : 'Address *',
                          hintText: i18n.isArabic ? 'طريق الملك فهد، حي الصحافة' : 'King Fahd Rd, Al Sahafa',
                          prefixIcon: const Icon(IconlyLight.paper),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return i18n.isArabic ? 'يرجى إدخال العنوان' : 'Address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone and Hours Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: i18n.isArabic ? 'رقم الهاتف' : 'Contact Phone',
                                hintText: '0501112233',
                                prefixIcon: const Icon(IconlyLight.call),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _openingHoursController,
                              decoration: InputDecoration(
                                labelText: i18n.isArabic ? 'ساعات العمل' : 'Opening Hours',
                                hintText: '08:00 AM - 11:00 PM',
                                prefixIcon: const Icon(IconlyLight.time_circle),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
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
                            i18n.isArabic ? 'تفعيل الفرع' : 'Branch Active',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            i18n.isArabic
                                ? 'إتاحة الفرع للاستلام من قبل العملاء'
                                : 'Make branch available for pickup in customer app',
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
                            isEdit ? (i18n.isArabic ? 'حفظ التعديلات' : 'Save Changes') : (i18n.isArabic ? 'إضافة الفرع' : 'Add Branch'),
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
