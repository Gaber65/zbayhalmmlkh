import 'payment_status.dart';

class PaymentResult {
  final AppPaymentStatus status;
  final String? paymentId;
  final String? errorMessage;

  PaymentResult({
    required this.status,
    this.paymentId,
    this.errorMessage,
  });
}
