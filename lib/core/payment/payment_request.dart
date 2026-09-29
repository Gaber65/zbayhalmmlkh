class PaymentRequest {
  final int orderId;
  final String orderNumber;
  final double amount;
  final String currency;
  final String paymentMethodCode;
  final String? publishableKey;
  final int? amountMinorUnits;
  final String? paymentUrl;

  PaymentRequest({
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.currency,
    required this.paymentMethodCode,
    this.publishableKey,
    this.amountMinorUnits,
    this.paymentUrl,
  });
}
