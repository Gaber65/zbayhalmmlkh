import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import '../../features/user/orders/presentation/views/payment_webview_screen.dart';
import 'payment_gateway.dart';
import 'payment_request.dart';
import 'payment_result.dart';
import 'payment_status.dart';

/// Concrete [PaymentGateway] implementation for the MyFatoorah payment gateway.
///
/// Supports KSA payment methods:
/// - Mada cards
/// - Visa / Mastercard
/// - Apple Pay / STC Pay
class MyFatoorahPaymentGateway implements PaymentGateway {
  @override
  String get name => 'myfatoorah';

  @override
  Future<PaymentResult> processPayment(
    BuildContext context,
    PaymentRequest request,
  ) async {
    String? url = request.paymentUrl;

    // If paymentUrl wasn't pre-populated, initiate the session via API
    if (url == null || url.isEmpty) {
      try {
        final dio = getIt<Dio>();
        final response = await dio.post(
          '/api/v1/payments/myfatoorah/initiate',
          data: {
            'order_id': request.orderId,
            'payment_method_code': request.paymentMethodCode,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final dynamic data = response.data['data'] ?? response.data;
          url = data['payment_url'] as String?;
        }
      } catch (e) {
        return PaymentResult(
          status: AppPaymentStatus.failed,
          errorMessage: 'فشل في تهيئة جلسة الدفع مع ماي فاتورة: $e',
        );
      }
    }

    if (url == null || url.isEmpty) {
      return PaymentResult(
        status: AppPaymentStatus.failed,
        errorMessage: 'تعذر الحصول على رابط الدفع من بوابة ماي فاتورة',
      );
    }

    if (!context.mounted) {
      return PaymentResult(status: AppPaymentStatus.failed);
    }

    // Open secure In-App WebView
    final paymentId = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(
          paymentUrl: url!,
          orderId: request.orderId,
        ),
      ),
    );

    if (paymentId != null && paymentId.isNotEmpty) {
      return PaymentResult(
        status: AppPaymentStatus.paid,
        paymentId: paymentId,
      );
    }

    return PaymentResult(
      status: AppPaymentStatus.failed,
      errorMessage: 'تم إلغاء عملية الدفع أو لم تكتمل',
    );
  }
}
