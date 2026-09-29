import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';
import 'admin_image_upload_picker.dart';

class BannerFormDialog extends StatefulWidget {
  final AdminBannerEntity? banner;
  final Future<bool> Function(Map<String, dynamic> data) onSave;

  const BannerFormDialog({
    super.key,
    this.banner,
    required this.onSave,
  });

  @override
  State<BannerFormDialog> createState() => _BannerFormDialogState();
}

class _BannerFormDialogState extends State<BannerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _linkController;
  String? _base64Image;
  String? _currentImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _linkController = TextEditingController(text: widget.banner?.link ?? '');
    _currentImageUrl = widget.banner?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final i18n = AdminI18n.of(context);
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      if (_base64Image == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(i18n.isArabic ? 'يرجى اختيار صورة للبنر' : 'Please select a banner image'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isSaving = true);
      final payload = <String, dynamic>{
        'title': _titleController.text.trim(),
        'name': _titleController.text.trim(),
        if (_linkController.text.isNotEmpty) 'link': _linkController.text.trim(),
        if (_base64Image != null) 'image': _base64Image,
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
    final isEdit = widget.banner != null;
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
                    child: const Icon(IconlyBold.image, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit ? (i18n.isArabic ? 'تعديل البنر الإعلاني' : 'Edit Banner') : i18n.addBanner,
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
                    // Direct Device Image Upload
                    AdminImageUploadPicker(
                      initialImageUrl: _currentImageUrl,
                      label: i18n.imageUploadLabel,
                      onImagePicked: ({imagePath, base64Image, imageBytes, fileName}) {
                        setState(() {
                          _base64Image = base64Image;
                        });
                      },
                      onImageRemoved: () {
                        setState(() {
                          _base64Image = null;
                          _currentImageUrl = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '${i18n.isArabic ? 'عنوان البنر / الحملة' : 'Banner Title'} *',
                        hintText: i18n.isArabic ? 'مثال: عروض نهاية الأسبوع الكبرى' : 'e.g. Mega Weekend Sales',
                        prefixIcon: const Icon(IconlyLight.paper),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? i18n.fieldRequired : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        labelText: i18n.isArabic ? 'رابط التوجيه (اختياري)' : 'Target Link (optional)',
                        hintText: 'e.g. /category/1',
                        prefixIcon: const Icon(Icons.link_rounded),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
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
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                            )
                          : Text(isEdit ? i18n.save : i18n.addBanner, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

