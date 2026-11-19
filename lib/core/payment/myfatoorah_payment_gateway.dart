import 'package:flutter/material.dart';
import 'payment_gateway.dart';
import 'payment_request.dart';
import 'payment_result.dart';
import 'payment_status.dart';

/// Legacy stub for historical compatibility only.
/// MyFatoorah is removed from active payment flows; Moyasar (`moyasar`) is the sole active gateway.
class MyFatoorahPaymentGateway implements PaymentGateway {
  @override
  String get name => 'myfatoorah';

  @override
  Future<PaymentResult> processPayment(
    BuildContext context,
    PaymentRequest request,
  ) async {
    return const PaymentResult(
      status: AppPaymentStatus.failed,
      errorMessage:
          'تم إيقاف بوابة الدفع ماي فاتورة نهائياً. البوابة المعتمدة هي ميسر (Moyasar).',
    );
  }
}
