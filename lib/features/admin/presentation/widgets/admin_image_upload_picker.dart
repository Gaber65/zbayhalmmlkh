import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../core/admin_i18n.dart';

class AdminImageUploadPicker extends StatefulWidget {
  final String? initialImageUrl;
  final String? label;
  final Function({
    String? imagePath,
    String? base64Image,
    Uint8List? imageBytes,
    String? fileName,
  }) onImagePicked;
  final VoidCallback? onImageRemoved;

  const AdminImageUploadPicker({
    super.key,
    this.initialImageUrl,
    this.label,
    required this.onImagePicked,
    this.onImageRemoved,
  });

  @override
  State<AdminImageUploadPicker> createState() => _AdminImageUploadPickerState();
}

class _AdminImageUploadPickerState extends State<AdminImageUploadPicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  Uint8List? _pickedBytes;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Str = base64Encode(bytes);

        setState(() {
          _pickedFile = image;
          _pickedBytes = bytes;
          _isLoading = false;
        });

        widget.onImagePicked(
          imagePath: kIsWeb ? null : image.path,
          base64Image: base64Str,
          imageBytes: bytes,
          fileName: image.name,
        );
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSourceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                i18n.isArabic ? 'اختر مصدر الصورة' : 'Select Image Source',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickImage(ImageSource.gallery);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            const Icon(IconlyBold.image, color: AppColors.primary, size: 30),
                            const SizedBox(height: 8),
                            Text(i18n.isArabic ? 'معرض الصور' : 'Photo Gallery', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickImage(ImageSource.camera);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            const Icon(IconlyBold.camera, color: AppColors.primary, size: 30),
                            const SizedBox(height: 8),
                            Text(i18n.isArabic ? 'التقاط بالكاميرا' : 'Take Photo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _pickedFile = null;
      _pickedBytes = null;
    });
    if (widget.onImageRemoved != null) {
      widget.onImageRemoved!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);
    final hasImage = _pickedBytes != null || (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty);
    final displayLabel = widget.label ?? i18n.imageUploadLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white70 : AppColors.secondary,
              ),
            ),
            if (hasImage)
              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(IconlyLight.delete, size: 14, color: Colors.red),
                label: Text(i18n.delete, style: const TextStyle(color: Colors.red, fontSize: 12)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isLoading ? null : _showSourceSheet,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151518) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasImage
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : (isDark ? Colors.white12 : Colors.grey.shade300),
                width: hasImage ? 1.5 : 1.0,
              ),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_pickedBytes != null)
                              Image.memory(_pickedBytes!, fit: BoxFit.cover)
                            else if (!kIsWeb && _pickedFile != null)
                              Image.file(File(_pickedFile!.path), fit: BoxFit.cover)
                            else
                              Image.network(
                                widget.initialImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(IconlyLight.image, size: 40, color: Colors.grey),
                                ),
                              ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(IconlyLight.edit, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(i18n.isArabic ? 'تغيير الصورة' : 'Change Image', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(IconlyBold.upload, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            i18n.isArabic ? 'اضغط لاختيار صورة من الجهاز أو الكاميرا' : 'Tap to upload image from device or camera',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            i18n.isArabic ? 'يدعم JPG, PNG, WEBP بدقة عالية' : 'Supports JPG, PNG, WEBP high resolution',
                            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}

