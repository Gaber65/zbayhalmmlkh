import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dio/dio.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/entities/order_entity.dart';

class InvoicePreviewSheet extends StatelessWidget {
  final OrderDetailEntity order;
  final bool isAdmin;

  const InvoicePreviewSheet({
    super.key,
    required this.order,
    this.isAdmin = false,
  });

  static Future<void> show(
    BuildContext context, {
    required OrderDetailEntity order,
    bool isAdmin = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InvoicePreviewSheet(order: order, isAdmin: isAdmin),
    );
  }

  Future<String> _getPdfUrl() async {
    try {
      final dio = getIt<Dio>();
      final baseUrl = dio.options.baseUrl;
      String token = '';

      try {
        final secureStorage = getIt<FlutterSecureStorage>();
        final st = await secureStorage.read(key: 'access_token');
        if (st != null && st.isNotEmpty) {
          token = st;
        }
      } catch (_) {}

      if (token.isEmpty) {
        try {
          final prefs = getIt<SharedPreferences>();
          final cachedUserStr = prefs.getString('CACHED_USER');
          if (cachedUserStr != null) {
            final Map<String, dynamic> userMap = json.decode(cachedUserStr);
            token = (userMap['access_token'] ?? userMap['token'] ?? userMap['accessToken'] ?? '') as String;
          }
        } catch (_) {}
      }

      final queryParam = token.isNotEmpty ? '?token=${Uri.encodeComponent(token)}' : '';
      return '$baseUrl${ServerStrings.orderInvoicePdf(order.id)}$queryParam';
    } catch (_) {
      return '';
    }
  }

  void _openPdf(BuildContext context) async {
    final pdfUrl = await _getPdfUrl();
    if (pdfUrl.isNotEmpty) {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر فتح ملف الفاتورة')),
          );
        }
      }
    }
  }

  String _generateShareText() {
    final buffer = StringBuffer();
    buffer.writeln('🧾 *فاتورة ضريبية مبسطة - ذبائح المملكة*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📋 رقم الطلب: ${order.name}');
    buffer.writeln('📅 التاريخ: ${order.date}');
    if (order.customerName != null && order.customerName!.isNotEmpty) {
      buffer.writeln('👤 العميل: ${order.customerName}');
    }
    if (order.shippingAddress != null && order.shippingAddress!.isNotEmpty) {
      buffer.writeln('📍 العنوان: ${order.shippingAddress}');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🛒 *المشتريات:*');
    for (final line in order.lines) {
      buffer.write('• ${line.name} (x${line.quantity.toInt()}): ${line.priceSubtotal.toStringAsFixed(2)} ر.س');
      final options = <String>[];
      if (line.cuttingOption != null) options.add('تقطيع: ${line.cuttingOption!.name}');
      if (line.packaging != null) options.add('تغليف: ${line.packaging!.name}');
      if (options.isNotEmpty) {
        buffer.write(' [${options.join(' - ')}]');
      }
      buffer.writeln();
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('💰 المجموع الفرعي: ${order.subtotal.toStringAsFixed(2)} ر.س');
    if (order.discountAmount > 0) {
      buffer.writeln('🏷️ الخصم: -${order.discountAmount.toStringAsFixed(2)} ر.س');
    }
    if (order.taxAmount > 0) {
      buffer.writeln('📊 الضريبة (15%): ${order.taxAmount.toStringAsFixed(2)} ر.س');
    }
    if (order.deliveryFee > 0) {
      buffer.writeln('🚚 التوصيل المبرد: ${order.deliveryFee.toStringAsFixed(2)} ر.س');
    } else {
      buffer.writeln('🚚 التوصيل: مجاني');
    }
    buffer.writeln('💵 *الإجمالي النهائي: ${order.total.toStringAsFixed(2)} ر.س*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('الرقم الضريبي: 310198765400003');
    buffer.writeln('للتواصل والدعم: 920000000');
    return buffer.toString();
  }

  void _shareViaWhatsApp(BuildContext context, {String? targetPhone}) async {
    final text = _generateShareText();
    String urlStr;
    if (targetPhone != null && targetPhone.isNotEmpty) {
      final clean = targetPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final fullNumber = clean.startsWith('05') ? '966${clean.substring(1)}' : clean;
      urlStr = 'https://wa.me/$fullNumber?text=${Uri.encodeComponent(text)}';
    } else {
      urlStr = 'https://wa.me/?text=${Uri.encodeComponent(text)}';
    }

    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ بيانات الفاتورة للحافظة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 10.h),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'فاتورة ضريبية مبسطة',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              order.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: 'monospace',
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Invoice Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Seller Information Card
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF282830) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ذبائح المملكة',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Dhabayih Lmamlaka',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'الرقم الضريبي: 310198765400003',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'السجل التجاري: 1010892341',
                                style: TextStyle(fontSize: 11.sp, color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        // QR Code representation
                        Container(
                          width: 68.w,
                          height: 68.w,
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Image.network(
                            'https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=${Uri.encodeComponent("Seller:Dhabayih Lmamlaka|VAT:310198765400003|Total:${order.total}|Date:${order.date}")}',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_2, size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // 2. Order & Customer Meta Grid
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF282830) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildMetaRow('تاريخ ووقت الفاتورة', order.date, cs),
                        const Divider(height: 12),
                        _buildMetaRow('العميل', order.customerName ?? 'عميل محترم', cs),
                        if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
                          const Divider(height: 12),
                          _buildMetaRow('الجوال', order.customerPhone!, cs, isMono: true),
                        ],
                        const Divider(height: 12),
                        _buildMetaRow(
                          'طريقة الاستلام',
                          order.deliveryType == 'pickup' ? 'استلام من المسلخ / الفرع' : 'توصيل مبرد للعنوان',
                          cs,
                        ),
                        if (order.shippingAddress != null && order.shippingAddress!.isNotEmpty) ...[
                          const Divider(height: 12),
                          _buildMetaRow('العنوان / الفرع', order.shippingAddress!, cs),
                        ],
                        const Divider(height: 12),
                        _buildMetaRow(
                          'طريقة السداد',
                          order.paymentMethod ?? 'دفع إلكتروني',
                          cs,
                        ),
                        const Divider(height: 12),
                        _buildMetaRow(
                          'حالة الدفع',
                          order.paymentStatus == 'paid' ? 'مدفوع بالكامل ✓' : 'قيد السداد ⏳',
                          cs,
                          valueColor: order.paymentStatus == 'paid' ? Colors.green : Colors.amber.shade800,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 3. Products List
                  Text(
                    'بنود الذبائح والمشتريات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.lines.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.h),
                    itemBuilder: (context, idx) {
                      final line = order.lines[idx];
                      return Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF282830) : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    line.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${line.priceSubtotal.toStringAsFixed(2)} ر.س',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: AppColors.primary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'الكمية: ${line.quantity.toInt()} × ${line.priceUnit.toStringAsFixed(2)} ر.س',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            if (line.cuttingOption != null || line.packaging != null || line.excludedParts.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Wrap(
                                spacing: 6.w,
                                runSpacing: 4.h,
                                children: [
                                  if (line.cuttingOption != null)
                                    _buildBadge('✂️ ${line.cuttingOption!.name}'),
                                  if (line.packaging != null)
                                    _buildBadge('📦 ${line.packaging!.name}'),
                                  if (line.excludedParts.isNotEmpty)
                                    _buildBadge('🚫 بدون: ${line.excludedParts.map((p) => p.name).join(", ")}'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16.h),

                  // 4. Totals Summary
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF282830) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildTotalLine('المجموع الفرعي (قبل الضريبة):', '${order.subtotal.toStringAsFixed(2)} ر.س', cs),
                        if (order.discountAmount > 0) ...[
                          SizedBox(height: 6.h),
                          _buildTotalLine('الخصم:', '- ${order.discountAmount.toStringAsFixed(2)} ر.س', cs, isDiscount: true),
                        ],
                        if (order.loyaltyDiscountAmount > 0) ...[
                          SizedBox(height: 6.h),
                          _buildTotalLine('خصم نقاط الولاء:', '- ${order.loyaltyDiscountAmount.toStringAsFixed(2)} ر.س', cs, isDiscount: true),
                        ],
                        SizedBox(height: 6.h),
                        _buildTotalLine('ضريبة القيمة المضافة (15%):', '${order.taxAmount.toStringAsFixed(2)} ر.س', cs),
                        SizedBox(height: 6.h),
                        _buildTotalLine(
                          'رسوم التوصيل المبرد:',
                          order.deliveryFee > 0 ? '${order.deliveryFee.toStringAsFixed(2)} ر.س' : 'مجاني',
                          cs,
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الإجمالي الكلي المستحق:',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14.sp,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${order.total.toStringAsFixed(2)} ر.س',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16.sp,
                                color: AppColors.primary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Legal notice
                  Center(
                    child: Text(
                      'فاتورة إلكترونية صادرة ومعتمدة وفق ضوابط هيئة الزكاة والضريبة والجمارك (ZATCA)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.sp, color: cs.onSurfaceVariant),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF24242B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // WhatsApp Share
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareViaWhatsApp(
                          context,
                          targetPhone: isAdmin ? order.customerPhone : null,
                        ),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          isAdmin ? 'مشاركة مع العميل' : 'مشاركة عبر واتساب',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // PDF Download / Print
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openPdf(context),
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                        label: Text(
                          'تحميل / طباعة PDF',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, ColorScheme cs, {bool isMono = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: cs.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? cs.onSurface,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalLine(String label, String value, ColorScheme cs, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDiscount ? Colors.red : cs.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: isDiscount ? Colors.red : cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: const Color(0xFF334155),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
