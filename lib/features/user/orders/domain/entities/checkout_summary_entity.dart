class CheckoutSummaryEntity {
  final Map<String, dynamic> cartSummary;
  final List<Map<String, dynamic>> deliveryMethods;
  final Map<String, dynamic>? defaultAddress;
  final List<Map<String, dynamic>> paymentMethods;
  final Map<String, dynamic> orderSummary;

  CheckoutSummaryEntity({
    required this.cartSummary,
    required this.deliveryMethods,
    this.defaultAddress,
    required this.paymentMethods,
    required this.orderSummary,
  });

  factory CheckoutSummaryEntity.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryEntity(
      cartSummary: json['cart_summary'] ?? {},
      deliveryMethods: List<Map<String, dynamic>>.from(json['delivery_methods'] ?? []),
      defaultAddress: json['default_address'],
      paymentMethods: List<Map<String, dynamic>>.from(json['payment_methods'] ?? []),
      orderSummary: json['order_summary'] ?? {},
    );
  }
}
