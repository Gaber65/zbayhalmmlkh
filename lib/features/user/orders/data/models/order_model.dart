import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import '../../domain/entities/order_entity.dart';

String? _parseString(dynamic val) {
  if (val == null || val == false) return null;
  return val.toString();
}

double _parseDouble(dynamic val) {
  if (val == null || val == false) return 0.0;
  return (val as num).toDouble();
}

int _parseInt(dynamic val) {
  if (val == null || val == false) return 0;
  return (val as num).toInt();
}

class OrderListItemModel {
  final int id;
  final String name;
  final String date;
  final String state;
  final String paymentStatus;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double total;
  final int itemCount;
  final String? paymentMethod;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryType;
  final double? deliveryFee;

  OrderListItemModel({
    required this.id,
    required this.name,
    required this.date,
    required this.state,
    required this.paymentStatus,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
    required this.itemCount,
    this.paymentMethod,
    this.customerName,
    this.customerPhone,
    this.deliveryType,
    this.deliveryFee,
  });

  factory OrderListItemModel.fromJson(Map<String, dynamic> json) {
    String? custName;
    String? custPhone;
    if (json['customer'] is Map) {
      custName = _parseString(json['customer']['name']);
      custPhone = _parseString(json['customer']['phone']);
    } else {
      custName = _parseString(json['customer_name']) ?? _parseString(json['customer']);
      custPhone = _parseString(json['customer_phone']) ?? _parseString(json['phone']);
    }

    return OrderListItemModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']) ?? '',
      date: _parseString(json['date']) ?? '',
      state: _parseString(json['state']) ?? '',
      paymentStatus: _parseString(json['payment_status']) ?? '',
      subtotal: _parseDouble(json['subtotal']),
      discountAmount: _parseDouble(json['discount_amount']),
      taxAmount: _parseDouble(json['tax_amount']),
      total: _parseDouble(json['total']),
      itemCount: _parseInt(json['item_count']),
      paymentMethod: _parseString(json['payment_method']),
      customerName: custName,
      customerPhone: custPhone,
      deliveryType: _parseString(json['delivery_type']),
      deliveryFee: _parseDouble(json['delivery_fee']),
    );
  }

  OrderListItemEntity toDomain() => OrderListItemEntity(
        id: id,
        name: name,
        date: date,
        state: state,
        paymentStatus: paymentStatus,
        subtotal: subtotal,
        discountAmount: discountAmount,
        taxAmount: taxAmount,
        total: total,
        itemCount: itemCount,
        paymentMethod: paymentMethod,
        customerName: customerName,
        customerPhone: customerPhone,
        deliveryType: deliveryType,
        deliveryFee: deliveryFee,
      );
}

class OrderLineModel {
  final int id;
  final int? productId;
  final String name;
  final double priceUnit;
  final double quantity;
  final double discount;
  final double priceSubtotal;
  final double discountAmount;
  final Map<String, dynamic>? cuttingOption;
  final Map<String, dynamic>? packaging;
  final List<dynamic> excludedParts;

  OrderLineModel({
    required this.id,
    this.productId,
    required this.name,
    required this.priceUnit,
    required this.quantity,
    required this.discount,
    required this.priceSubtotal,
    required this.discountAmount,
    this.cuttingOption,
    this.packaging,
    this.excludedParts = const [],
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) {
    return OrderLineModel(
      id: _parseInt(json['id']),
      productId: json['product_id'] != null ? _parseInt(json['product_id']) : null,
      name: _parseString(json['name']) ?? '',
      priceUnit: _parseDouble(json['price_unit']),
      quantity: _parseDouble(json['quantity']),
      discount: _parseDouble(json['discount']),
      priceSubtotal: _parseDouble(json['price_subtotal']),
      discountAmount: _parseDouble(json['discount_amount']),
      cuttingOption: json['cutting_option'] is Map<String, dynamic>
          ? json['cutting_option'] as Map<String, dynamic>
          : null,
      packaging: json['packaging'] is Map<String, dynamic>
          ? json['packaging'] as Map<String, dynamic>
          : null,
      excludedParts: json['excluded_parts'] is List ? json['excluded_parts'] as List : [],
    );
  }

  static ProductOption? _toOption(Map<String, dynamic>? map) {
    if (map == null) return null;
    return ProductOption(
      id: _parseInt(map['id']),
      name: _parseString(map['name']) ?? '',
    );
  }

  static List<ProductOption> _toOptionList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => ProductOption(
            id: _parseInt(e['id']),
            name: _parseString(e['name']) ?? '',
          ),
        )
        .toList();
  }

  OrderLineEntity toDomain() => OrderLineEntity(
        id: id,
        productId: productId,
        name: name,
        priceUnit: priceUnit,
        quantity: quantity,
        discount: discount,
        priceSubtotal: priceSubtotal,
        discountAmount: discountAmount,
        cuttingOption: _toOption(cuttingOption),
        packaging: _toOption(packaging),
        excludedParts: _toOptionList(excludedParts),
      );
}

class OrderTimelineModel {
  final int id;
  final String statusFrom;
  final String statusTo;
  final String description;
  final String timestamp;

  OrderTimelineModel({
    required this.id,
    required this.statusFrom,
    required this.statusTo,
    required this.description,
    required this.timestamp,
  });

  factory OrderTimelineModel.fromJson(Map<String, dynamic> json) {
    return OrderTimelineModel(
      id: _parseInt(json['id']),
      statusFrom: _parseString(json['status_from']) ?? '',
      statusTo: _parseString(json['status_to']) ?? '',
      description: _parseString(json['description']) ?? '',
      timestamp: _parseString(json['timestamp']) ?? '',
    );
  }

  OrderTimelineEntity toDomain() => OrderTimelineEntity(
        id: id,
        statusFrom: statusFrom,
        statusTo: statusTo,
        description: description,
        timestamp: timestamp,
      );
}

class OrderDetailModel {
  final int id;
  final String name;
  final String date;
  final String state;
  final String paymentStatus;
  final double subtotal;
  final double discountAmount;
  final String? couponCode;
  final int pointsRedeemed;
  final double loyaltyDiscountAmount;
  final double taxAmount;
  final double deliveryFee;
  final double total;
  final String? paymentMethod;
  final String? transactionRef;
  final String? notes;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? deliveryType;
  final String? shippingAddress;
  final int? loyaltyPointsEarned;
  final List<OrderLineModel> lines;
  final List<OrderTimelineModel> timeline;

  OrderDetailModel({
    required this.id,
    required this.name,
    required this.date,
    required this.state,
    required this.paymentStatus,
    required this.subtotal,
    required this.discountAmount,
    this.couponCode,
    required this.pointsRedeemed,
    required this.loyaltyDiscountAmount,
    required this.taxAmount,
    this.deliveryFee = 0.0,
    required this.total,
    this.paymentMethod,
    this.transactionRef,
    this.notes,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.deliveryType,
    this.shippingAddress,
    this.loyaltyPointsEarned,
    required this.lines,
    required this.timeline,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? [];
    final rawTimeline = json['timeline'] as List<dynamic>? ?? [];

    String? custName;
    String? custPhone;
    String? custEmail;
    if (json['customer'] is Map) {
      custName = _parseString(json['customer']['name']);
      custPhone = _parseString(json['customer']['phone']);
      custEmail = _parseString(json['customer']['email']);
    } else {
      custName = _parseString(json['customer_name']) ?? _parseString(json['customer']);
      custPhone = _parseString(json['customer_phone']) ?? _parseString(json['phone']);
      custEmail = _parseString(json['customer_email']) ?? _parseString(json['email']);
    }

    String? shipAddr;
    if (json['address'] is Map) {
      final a = json['address'] as Map<String, dynamic>;
      final city = _parseString(a['city']) ?? '';
      final street = _parseString(a['street']) ?? _parseString(a['address']) ?? '';
      shipAddr = [city, street].where((s) => s.isNotEmpty).join(' - ');
    } else {
      shipAddr = _parseString(json['shipping_address']) ?? _parseString(json['address']);
    }

    return OrderDetailModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']) ?? '',
      date: _parseString(json['date']) ?? '',
      state: _parseString(json['state']) ?? '',
      paymentStatus: _parseString(json['payment_status']) ?? '',
      subtotal: _parseDouble(json['subtotal']),
      discountAmount: _parseDouble(json['discount_amount']),
      couponCode: _parseString(json['coupon_code']),
      pointsRedeemed: _parseInt(json['points_redeemed']),
      loyaltyDiscountAmount: _parseDouble(json['loyalty_discount_amount']),
      taxAmount: _parseDouble(json['tax_amount']),
      deliveryFee: _parseDouble(json['delivery_fee']),
      total: _parseDouble(json['total']),
      paymentMethod: _parseString(json['payment_method']),
      transactionRef: _parseString(json['transaction_ref']) ?? _parseString(json['payment_ref']),
      notes: _parseString(json['notes']) ?? _parseString(json['internal_notes']),
      customerName: custName,
      customerPhone: custPhone,
      customerEmail: custEmail,
      deliveryType: _parseString(json['delivery_type']),
      shippingAddress: shipAddr,
      loyaltyPointsEarned: _parseInt(json['loyalty_points_earned']),
      lines: rawLines
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderLineModel.fromJson(e))
          .toList(),
      timeline: rawTimeline
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderTimelineModel.fromJson(e))
          .toList(),
    );
  }

  OrderDetailEntity toDomain() => OrderDetailEntity(
        id: id,
        name: name,
        date: date,
        state: state,
        paymentStatus: paymentStatus,
        subtotal: subtotal,
        discountAmount: discountAmount,
        couponCode: couponCode,
        pointsRedeemed: pointsRedeemed,
        loyaltyDiscountAmount: loyaltyDiscountAmount,
        taxAmount: taxAmount,
        deliveryFee: deliveryFee,
        total: total,
        paymentMethod: paymentMethod,
        transactionRef: transactionRef,
        notes: notes,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        deliveryType: deliveryType,
        shippingAddress: shippingAddress,
        loyaltyPointsEarned: loyaltyPointsEarned,
        lines: lines.map((e) => e.toDomain()).toList(),
        timeline: timeline.map((e) => e.toDomain()).toList(),
      );
}

class CheckoutResultModel {
  final int orderId;
  final String orderNumber;
  final String state;
  final String paymentStatus;
  final double subtotal;
  final double discountAmount;
  final int pointsRedeemed;
  final double loyaltyDiscountAmount;
  final double total;
  final String? paymentUrl;
  final String? publishableKey;
  final int? amountMinorUnits;

  CheckoutResultModel({
    required this.orderId,
    required this.orderNumber,
    required this.state,
    required this.paymentStatus,
    required this.subtotal,
    required this.discountAmount,
    required this.pointsRedeemed,
    required this.loyaltyDiscountAmount,
    required this.total,
    this.paymentUrl,
    this.publishableKey,
    this.amountMinorUnits,
  });

  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResultModel(
      orderId: _parseInt(json['order_id']),
      orderNumber: _parseString(json['order_number']) ?? '',
      state: _parseString(json['state']) ?? '',
      paymentStatus: _parseString(json['payment_status']) ?? '',
      subtotal: _parseDouble(json['subtotal']),
      discountAmount: _parseDouble(json['discount_amount']),
      pointsRedeemed: _parseInt(json['points_redeemed']),
      loyaltyDiscountAmount: _parseDouble(json['loyalty_discount_amount']),
      total: _parseDouble(json['total']),
      paymentUrl: _parseString(json['payment_url']),
      publishableKey: _parseString(json['publishable_key']),
      amountMinorUnits: _parseInt(json['amount_minor_units']),
    );
  }

  CheckoutResultEntity toDomain() => CheckoutResultEntity(
        orderId: orderId,
        orderNumber: orderNumber,
        state: state,
        paymentStatus: paymentStatus,
        subtotal: subtotal,
        discountAmount: discountAmount,
        pointsRedeemed: pointsRedeemed,
        loyaltyDiscountAmount: loyaltyDiscountAmount,
        total: total,
        paymentUrl: paymentUrl,
        publishableKey: publishableKey,
        amountMinorUnits: amountMinorUnits,
      );
}
