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

  /// Validates that a Moyasar publishable key satisfies the SDK contract
  /// (`pk_test_...` or `pk_live_...`, non-placeholder) before constructing
  /// `PaymentConfig` so Dart `AssertionError` ("Condition Error") is never thrown.
  static bool isValidPublishableKey(String? key) {
    if (key == null) return false;
    final trimmed = key.trim();
    if (trimmed.length <= 12) return false;
    final lower = trimmed.toLowerCase();
    if (lower.contains('placeholder') || lower.contains('dummy')) {
      return false;
    }
    return trimmed.startsWith('pk_test_') || trimmed.startsWith('pk_live_');
  }

  static int resolveAmountMinorUnits(PaymentRequest request) {
    if (request.amountMinorUnits != null && request.amountMinorUnits! > 0) {
      return request.amountMinorUnits!;
    }
    return (request.amount * 100).round();
  }

  @override
  Future<PaymentResult> processPayment(
    BuildContext context,
    PaymentRequest request,
  ) async {
    final amountHalalas = resolveAmountMinorUnits(request);
    if (amountHalalas < 100 || request.amount <= 0) {
      return const PaymentResult(
        status: AppPaymentStatus.failed,
        errorMessage: 'الحد الأدنى للدفع الإلكتروني عبر ميسر هو 1.00 ر.س',
      );
    }

    // 1. Fetch official Moyasar Invoice payment URL from backend
    String? url = request.paymentUrl;
    String? effectivePublishableKey = request.publishableKey;
    String? initiateErrorMessage;

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
          if (data is Map) {
            url = data['payment_url'] as String?;
            final respKey = data['publishable_key'] as String?;
            if (isValidPublishableKey(respKey)) {
              effectivePublishableKey = respKey!.trim();
            }
          }
        }
      } on DioException catch (e) {
        final respData = e.response?.data;
        if (respData is Map && respData['message'] != null) {
          initiateErrorMessage = respData['message'].toString();
        }
        debugPrint('Failed to initiate Moyasar payment invoice: $e');
      } catch (e) {
        debugPrint('Failed to initiate Moyasar payment invoice: $e');
      }
    }

    if (!context.mounted) {
      return const PaymentResult(status: AppPaymentStatus.cancelled);
    }

    // 2. Web Platform handling: redirect to Moyasar Invoice payment page
    if (kIsWeb) {
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
        return const PaymentResult(status: AppPaymentStatus.pending);
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

      if (paymentId != null && paymentId.isNotEmpty) {
        return PaymentResult(
          status: AppPaymentStatus.paid,
          paymentId: paymentId,
        );
      }
      return const PaymentResult(status: AppPaymentStatus.failed);
    }

    // 4. Fallback: native card screen ONLY if a valid Moyasar publishable key is configured
    if (!isValidPublishableKey(effectivePublishableKey)) {
      return PaymentResult(
        status: AppPaymentStatus.failed,
        errorMessage: initiateErrorMessage ??
            'بوابة الدفع الإلكتروني (ميسر) غير مهيأة بمفتاح صالح حالياً. يرجى اختيار الدفع عند الاستلام أو مراجعة إعدادات الدفع.',
      );
    }

    final paymentId = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => NativePaymentScreen(
          publishableKey: effectivePublishableKey!.trim(),
          amountMinorUnits: amountHalalas,
          orderId: request.orderId,
          orderNumber: request.orderNumber,
          totalAmount: request.amount,
          paymentMethodCode: request.paymentMethodCode,
        ),
      ),
    );

    if (paymentId != null && paymentId.isNotEmpty) {
      return PaymentResult(status: AppPaymentStatus.paid, paymentId: paymentId);
    }
    return const PaymentResult(status: AppPaymentStatus.failed);
  }
}
