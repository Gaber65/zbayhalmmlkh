import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';

class CouponFormDialog extends StatefulWidget {
  final AdminCouponEntity? coupon;
  final Function(Map<String, dynamic> data) onSave;

  const CouponFormDialog({super.key, this.coupon, required this.onSave});

  @override
  State<CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _discountValueController;
  late TextEditingController _minOrderController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _maxUsesController;
  late TextEditingController _expiryDateController;
  String _discountType = 'percentage';

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    _codeController = TextEditingController(text: c?.code ?? '');
    _discountValueController = TextEditingController(
      text: c != null ? c.discountValue.toString() : '',
    );
    _minOrderController = TextEditingController(
      text: c != null ? c.minOrderValue.toString() : '0',
    );
    _maxDiscountController = TextEditingController(
      text: c?.maxDiscount != null ? c!.maxDiscount.toString() : '',
    );
    _maxUsesController = TextEditingController(
      text: c?.maxUses != null ? c!.maxUses.toString() : '',
    );
    _expiryDateController = TextEditingController(text: c?.expiryDate ?? '');
    _discountType = c?.discountType ?? 'percentage';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountValueController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _maxUsesController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final code = _codeController.text.trim().toUpperCase();
      final minVal = double.tryParse(_minOrderController.text) ?? 0.0;
      final maxUses = int.tryParse(_maxUsesController.text);
      final expiry = _expiryDateController.text.trim();

      widget.onSave({
        'code': code,
        'name': code,
        'discount_type': _discountType,
        'discount_value': double.tryParse(_discountValueController.text) ?? 0.0,
        'min_order_value': minVal,
        'minimum_order_amount': minVal,
        if (_maxDiscountController.text.isNotEmpty)
          'max_discount': double.tryParse(_maxDiscountController.text),
        if (maxUses != null) ...{
          'max_uses': maxUses,
          'usage_limit': maxUses,
        },
        if (expiry.isNotEmpty) 'expiry_date': expiry,
        if (expiry.isNotEmpty) 'end_date': expiry,
        'is_active': true,
        'active': true,
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.coupon != null;
    final i18n = AdminI18n.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                      IconlyBold.discount,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit
                          ? (i18n.isArabic ? 'تعديل كود الخصم' : 'Edit Coupon')
                          : i18n.addCoupon,
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: '${i18n.couponCode} *',
                          hintText: 'e.g. RAMADAN2026',
                          prefixIcon: const Icon(IconlyLight.discount),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? i18n.fieldRequired
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _discountType,
                        decoration: InputDecoration(
                          labelText: i18n.isArabic
                              ? 'نوع الخصم'
                              : 'Discount Type',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'percentage',
                            child: Text(
                              i18n.isArabic
                                  ? 'نسبة مئوية (%)'
                                  : 'Percentage (%)',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'fixed',
                            child: Text(
                              i18n.isArabic
                                  ? 'مبلغ ثابت (ر.س)'
                                  : 'Fixed Amount (SAR)',
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _discountType = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _discountValueController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: _discountType == 'percentage'
                                    ? (i18n.isArabic
                                          ? 'النسبة (%) *'
                                          : 'Percentage (%) *')
                                    : '${i18n.discountAmount} (${i18n.sar}) *',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                  ? i18n.fieldRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _minOrderController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: i18n.minOrderAmount,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _maxDiscountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText:
                                    '${i18n.isArabic ? 'أقصى خصم' : 'Max Cap'} (${i18n.sar})',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _maxUsesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: i18n.isArabic
                                    ? 'أقصى عدد استخدام'
                                    : 'Max Uses',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(
                          labelText:
                              '${i18n.isArabic ? 'تاريخ الانتهاء' : 'Expiry Date'} (YYYY-MM-DD)',
                          prefixIcon: const Icon(IconlyLight.time_circle),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        isEdit ? i18n.save : i18n.addCoupon,
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
