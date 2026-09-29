import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';

class OptionFormDialog extends StatefulWidget {
  final AdminOptionEntity? option;
  final String defaultType;
  final Function(Map<String, dynamic> data) onSave;

  const OptionFormDialog({
    super.key,
    this.option,
    required this.defaultType,
    required this.onSave,
  });

  @override
  State<OptionFormDialog> createState() => _OptionFormDialogState();
}

class _OptionFormDialogState extends State<OptionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late String _type;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final opt = widget.option;
    _nameController = TextEditingController(text: opt?.name ?? '');
    _descController = TextEditingController(text: opt?.description ?? '');
    _priceController = TextEditingController(
      text: opt != null ? opt.extraPrice.toString() : '0.0',
    );
    _type = opt?.type ?? widget.defaultType;
    _isActive = opt?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        if (widget.option != null) 'id': widget.option!.id,
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'extra_price': double.tryParse(_priceController.text) ?? 0.0,
        'type': _type,
        'is_active': _isActive,
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.option != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                      IconlyBold.ticket,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit
                          ? (i18n.isArabic
                                ? 'تعديل خيار التجهيز'
                                : 'Edit Customization Option')
                          : (i18n.isArabic
                                ? 'إضافة خيار تجهيز جديد'
                                : 'Add Customization Option'),
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _type,
                      decoration: InputDecoration(
                        labelText: i18n.isArabic
                            ? 'نوع الخيار والتصنيف'
                            : 'Option Type',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'cutting',
                          child: Text(
                            i18n.isArabic
                                ? 'خيارات التقطيع (تفصيل / ثلاجة / مفطح)'
                                : 'Cutting Options (Detailed/Fridge/Mofattah)',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'packaging',
                          child: Text(
                            i18n.isArabic
                                ? 'خيارات التغليف (أكياس / سحب هواء / صحون)'
                                : 'Packaging Options (Bags/Vacuum/Plates)',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'excluded_part',
                          child: Text(
                            i18n.isArabic
                                ? 'أجزاء مستثناة (بدون رأس / بدون أحشاء)'
                                : 'Excluded Parts (Without Head/Offal)',
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _type = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '${i18n.optionName} *',
                        hintText: i18n.isArabic
                            ? 'مثال: تقطيع ثلاجة صغير'
                            : 'e.g. Small Fridge Cut',
                        prefixIcon: const Icon(IconlyLight.paper),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? i18n.fieldRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${i18n.extraPrice} (${i18n.sar})',
                        hintText: '0.0',
                        prefixIcon: const Icon(IconlyLight.wallet),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: i18n.isArabic
                            ? 'وصف إضافي أو تعليمات (اختياري)'
                            : 'Additional description (optional)',
                        prefixIcon: const Icon(IconlyLight.document),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(i18n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEdit
                            ? i18n.save
                            : (i18n.isArabic ? 'إضافة الخيار' : 'Add Option'),
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
    );
  }
}
