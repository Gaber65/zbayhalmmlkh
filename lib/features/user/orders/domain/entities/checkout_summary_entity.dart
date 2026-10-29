class CheckoutSummaryEntity {
  final Map<String, dynamic> cartSummary;
  final List<Map<String, dynamic>> deliveryMethods;
  final Map<String, dynamic>? defaultAddress;
  final List<Map<String, dynamic>> paymentMethods;
  final Map<String, dynamic> orderSummary;
  final Map<String, dynamic> loyalty;

  CheckoutSummaryEntity({
    required this.cartSummary,
    required this.deliveryMethods,
    this.defaultAddress,
    required this.paymentMethods,
    required this.orderSummary,
    this.loyalty = const {},
  });

  int get availablePoints =>
      (loyalty['available_points'] as num?)?.toInt() ?? 0;

  double get earningRate =>
      (loyalty['earning_rate'] as num?)?.toDouble() ?? 1.0;

  double get redemptionRate =>
      (loyalty['redemption_rate'] as num?)?.toDouble() ?? 10.0;

  int get minRedemption =>
      (loyalty['min_redemption'] as num?)?.toInt() ?? 100;

  bool get isLoyaltyEligible =>
      loyalty['is_eligible'] as bool? ?? (availablePoints >= minRedemption);

  double get maxLoyaltyDiscountSar =>
      (loyalty['max_discount_sar'] as num?)?.toDouble() ??
      (redemptionRate > 0 ? availablePoints / redemptionRate : 0.0);

  factory CheckoutSummaryEntity.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryEntity(
      cartSummary: json['cart_summary'] is Map<String, dynamic>
          ? json['cart_summary'] as Map<String, dynamic>
          : {},
      deliveryMethods: List<Map<String, dynamic>>.from(json['delivery_methods'] ?? []),
      defaultAddress: json['default_address'] is Map<String, dynamic>
          ? json['default_address'] as Map<String, dynamic>
          : null,
      paymentMethods: List<Map<String, dynamic>>.from(json['payment_methods'] ?? []),
      orderSummary: json['order_summary'] is Map<String, dynamic>
          ? json['order_summary'] as Map<String, dynamic>
          : {},
      loyalty: json['loyalty'] is Map<String, dynamic>
          ? json['loyalty'] as Map<String, dynamic>
          : {},
    );
  }
}
