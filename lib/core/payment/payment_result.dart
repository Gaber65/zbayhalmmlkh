import 'payment_status.dart';

class PaymentResult {
  final AppPaymentStatus status;
  final String? paymentId;
  final String? errorMessage;

  const PaymentResult({
    required this.status,
    this.paymentId,
    this.errorMessage,
  });
}
