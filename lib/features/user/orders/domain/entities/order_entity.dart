import 'package:equatable/equatable.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';

class OrderListItemEntity extends Equatable {
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

  const OrderListItemEntity({
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

  @override
  List<Object?> get props => [
        id,
        name,
        date,
        state,
        paymentStatus,
        subtotal,
        discountAmount,
        taxAmount,
        total,
        itemCount,
        paymentMethod,
        customerName,
        customerPhone,
        deliveryType,
        deliveryFee,
      ];
}

class OrderLineEntity extends Equatable {
  final int id;
  final int? productId;
  final String name;
  final double priceUnit;
  final double quantity;
  final double discount;
  final double priceSubtotal;
  final double discountAmount;
  final ProductOption? cuttingOption;
  final ProductOption? packaging;
  final List<ProductOption> excludedParts;

  const OrderLineEntity({
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
    required this.excludedParts,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        name,
        priceUnit,
        quantity,
        discount,
        priceSubtotal,
        discountAmount,
        cuttingOption,
        packaging,
        excludedParts,
      ];
}

class OrderTimelineEntity extends Equatable {
  final int id;
  final String statusFrom;
  final String statusTo;
  final String description;
  final String timestamp;

  const OrderTimelineEntity({
    required this.id,
    required this.statusFrom,
    required this.statusTo,
    required this.description,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        statusFrom,
        statusTo,
        description,
        timestamp,
      ];
}

class OrderDetailEntity extends Equatable {
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
  final double total;
  final double deliveryFee;
  final String? paymentMethod;
  final String? transactionRef;
  final String? notes;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? deliveryType;
  final String? shippingAddress;
  final int? loyaltyPointsEarned;
  final List<OrderLineEntity> lines;
  final List<OrderTimelineEntity> timeline;

  const OrderDetailEntity({
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
    required this.total,
    this.deliveryFee = 0.0,
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

  bool get isCancellable =>
      state == 'draft' || state == 'pending_payment' || state == 'confirmed';

  bool get isReceivable =>
      state == 'out_delivery' || state == 'ready_pickup';

  @override
  List<Object?> get props => [
        id,
        name,
        date,
        state,
        paymentStatus,
        subtotal,
        discountAmount,
        couponCode,
        pointsRedeemed,
        loyaltyDiscountAmount,
        taxAmount,
        total,
        deliveryFee,
        paymentMethod,
        transactionRef,
        notes,
        customerName,
        customerPhone,
        customerEmail,
        deliveryType,
        shippingAddress,
        loyaltyPointsEarned,
        lines,
        timeline,
      ];
}

class CheckoutResultEntity extends Equatable {
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

  const CheckoutResultEntity({
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

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        state,
        paymentStatus,
        subtotal,
        discountAmount,
        pointsRedeemed,
        loyaltyDiscountAmount,
        total,
        paymentUrl,
        publishableKey,
        amountMinorUnits,
      ];
}
