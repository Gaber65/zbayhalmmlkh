import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import '../../features/user/orders/presentation/views/native_payment_screen.dart';
import '../../features/user/orders/presentation/views/payment_webview_screen.dart';
import 'payment_gateway.dart';
import 'payment_request.dart';
import 'payment_result.dart';
import 'payment_status.dart';

/// Concrete [PaymentGateway] implementation for the Moyasar payment provider.
///
/// Supports:
/// - Credit / Debit cards (Visa, Mastercard, Mada)
/// - STC Pay (Saudi Telecom)
/// - Web redirect on Flutter Web
///
/// The gateway name is 'moyasar' — this matches the `provider` field
/// returned by the backend for online payment methods.
class MoyasarPaymentGateway implements PaymentGateway {
  @override
  String get name => 'moyasar';

  @override
  Future<PaymentResult> processPayment(
    BuildContext context,
    PaymentRequest request,
  ) async {
    // 1. Fetch official Moyasar Invoice payment URL from backend
    String? url = request.paymentUrl;
    if (url == null || url.isEmpty) {
      try {
        final dio = getIt<Dio>();
        final response = await dio.post(
          '/api/v1/payments/moyasar/initiate',
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
        debugPrint('Failed to initiate Moyasar payment invoice: $e');
      }
    }

    // 2. Web Platform handling: redirect to Moyasar Invoice payment page
    if (kIsWeb) {
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
        return PaymentResult(status: AppPaymentStatus.pending);
      }
    }

    // 3. Native Mobile handling: open in-app PaymentWebViewScreen
    if (url != null && url.isNotEmpty) {
      final paymentId = await Navigator.push<String?>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: url!,
            orderId: request.orderId,
          ),
        ),
      );

      if (paymentId != null) {
        return PaymentResult(status: AppPaymentStatus.paid, paymentId: paymentId);
      }
      return PaymentResult(status: AppPaymentStatus.failed);
    }

    // 4. Fallback: native card screen if invoice URL is unavailable
    final paymentId = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => NativePaymentScreen(
          publishableKey: (request.publishableKey != null && request.publishableKey!.isNotEmpty)
              ? request.publishableKey!
              : 'pk_test_jmsPpaHEyAKUgFwNnLzhnzsCzbSPg11Lu7hN3Ex4',
          amountMinorUnits: (request.amountMinorUnits != null && request.amountMinorUnits! > 0)
              ? request.amountMinorUnits!
              : (request.amount * 100).round(),
          orderId: request.orderId,
          orderNumber: request.orderNumber,
          totalAmount: request.amount,
          paymentMethodCode: request.paymentMethodCode,
        ),
      ),
    );

    if (paymentId != null) {
      return PaymentResult(status: AppPaymentStatus.paid, paymentId: paymentId);
    }
    return PaymentResult(status: AppPaymentStatus.failed);
  }
}
