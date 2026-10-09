import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../core/admin_i18n.dart';

class BroadcastNotificationDialog extends StatefulWidget {
  final Future<bool> Function(String title, String body, String? topic) onSend;

  const BroadcastNotificationDialog({super.key, required this.onSend});

  @override
  State<BroadcastNotificationDialog> createState() => _BroadcastNotificationDialogState();
}

class _BroadcastNotificationDialogState extends State<BroadcastNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final String _targetTopic = 'topic:all';
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final i18n = AdminI18n.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSending = true;
        _errorMessage = null;
      });
      final success = await widget.onSend(
        _titleController.text.trim(),
        _bodyController.text.trim(),
        _targetTopic,
      );
      if (mounted) {
        setState(() {
          _isSending = false;
          if (!success) {
            _errorMessage = i18n.isArabic
                ? 'تعذر إرسال الإشعار، يرجى التحقق من اتصال الخادم والصلاحيات'
                : 'Failed to send notification. Please check server connection and permissions.';
          }
        });
        if (success) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(IconlyBold.notification, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i18n.isArabic ? 'إرسال إشعار عام للعملاء' : 'Broadcast Push Notification',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          i18n.isArabic ? 'سيصل الإشعار لجميع مستخدمي التطبيق فوراً' : 'Delivered instantly to all active customer devices',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white54 : AppColors.secondary,
                              ),
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
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '${i18n.isArabic ? 'عنوان الإشعار' : 'Notification Title'} *',
                        hintText: i18n.isArabic ? 'مثال: عروض نهاية الأسبوع على النعيمي البلدي' : 'e.g. Weekend Special Discounts',
                        prefixIcon: const Icon(IconlyLight.paper),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? i18n.fieldRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: '${i18n.isArabic ? 'نص رسالة الإشعار' : 'Notification Message'} *',
                        hintText: i18n.isArabic ? 'استمتع بخصم خاص وتوصيل مبرد سريع حتى باب منزلك!' : 'Enjoy exclusive discounts and fast refrigerated delivery to your doorstep!',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? i18n.fieldRequired : null,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _submit,
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(IconlyLight.send, size: 18, color: Colors.white),
                      label: Text(
                        _isSending ? (i18n.isArabic ? 'جاري الإرسال...' : 'Sending...') : (i18n.isArabic ? 'إرسال الإشعار الآن' : 'Send Push Now'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

