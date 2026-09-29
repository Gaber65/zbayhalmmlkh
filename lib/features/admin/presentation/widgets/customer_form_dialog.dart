import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';

class CustomerFormDialog extends StatefulWidget {
  final AdminUserEntity? user;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const CustomerFormDialog({
    super.key,
    this.user,
    required this.onSave,
  });

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _pointsController;

  late String _userType;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u?.name ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _passwordController = TextEditingController();
    _pointsController = TextEditingController(text: u != null ? '${u.loyaltyPoints}' : '0');
    _userType = u?.userType ?? 'individual';
    _isActive = (u?.status ?? 'active') == 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final points = int.tryParse(_pointsController.text.trim()) ?? 0;

    if (phone.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الجوال أو البريد الإلكتروني على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'name': name,
      if (phone.isNotEmpty) 'phone': phone,
      if (email.isNotEmpty) 'email': email,
      'user_type': _userType,
      'status': _isActive ? 'active' : 'suspended',
      if (password.isNotEmpty) 'password': password,
      if (widget.user == null && points > 0) 'loyalty_points': points,
    };

    final success = await widget.onSave(data);
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEdit ? IconlyBold.edit : Icons.person_add_alt_1_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? (i18n.isArabic ? 'تعديل بيانات العميل' : 'Edit Customer')
                                : (i18n.isArabic ? 'إضافة عميل جديد' : 'Add New Customer'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEdit
                                ? (i18n.isArabic ? 'تحديث معلومات الحساب وحالته' : 'Update account info & status')
                                : (i18n.isArabic ? 'إنشاء حساب عميل جديد في النظام' : 'Create new customer record'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
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
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'اسم العميل *' : 'Customer Name *',
                    prefixIcon: const Icon(IconlyLight.profile, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A32) : const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return i18n.isArabic ? 'يرجى إدخال اسم العميل' : 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'رقم الجوال' : 'Phone Number',
                    hintText: '05xxxxxxxx',
                    prefixIcon: const Icon(IconlyLight.call, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A32) : const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'البريد الإلكتروني' : 'Email Address',
                    hintText: 'name@example.com',
                    prefixIcon: const Icon(IconlyLight.message, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A32) : const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Password (optional if edit, required/optional default if new)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: isEdit
                        ? (i18n.isArabic ? 'كلمة المرور (اتركها فارغة للتخطي)' : 'Password (leave blank to keep)')
                        : (i18n.isArabic ? 'كلمة المرور (افتراضي: 123456)' : 'Password (default: 123456)'),
                    prefixIcon: const Icon(IconlyLight.lock, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A32) : const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Account Type Selector
                Text(
                  i18n.isArabic ? 'نوع الحساب' : 'Account Type',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(i18n.isArabic ? 'فردي (عميل)' : 'Individual'),
                        ),
                        selected: _userType == 'individual' || _userType == 'customer',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: (_userType == 'individual' || _userType == 'customer')
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _userType = 'individual');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(i18n.isArabic ? 'شركة / أعمال' : 'Business'),
                        ),
                        selected: _userType == 'business',
                        selectedColor: const Color(0xFF3B82F6),
                        labelStyle: TextStyle(
                          color: _userType == 'business'
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _userType = 'business');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A32) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              _isActive ? Icons.check_circle_outline : Icons.block,
                              color: _isActive ? const Color(0xFF10B981) : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i18n.isArabic ? 'حالة الحساب' : 'Account Status',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    _isActive
                                        ? (i18n.isArabic ? 'نشط - يمكنه الطلب وتسجيل الدخول' : 'Active - Can place orders')
                                        : (i18n.isArabic ? 'معلق - الحساب موقوف مؤقتاً' : 'Suspended - Temporarily blocked'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _isActive ? const Color(0xFF10B981) : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isActive,
                        activeTrackColor: const Color(0xFF10B981),
                        activeThumbColor: Colors.white,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(i18n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                isEdit ? i18n.save : (i18n.isArabic ? 'إنشاء العميل' : 'Create Customer'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
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
