import 'package:equatable/equatable.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';

/// A selected option (cutting / packaging / excluded part)
typedef OptionItem = ProductOption;

class CartLineEntity extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final double quantity;
  final double priceUnit;
  final double discountPercent;
  final double lineTotal;
  final ProductOption? cuttingOption;
  final List<ProductOption> packagingOptions;
  final List<ProductOption> excludedParts;
  final String? notes;

  const CartLineEntity({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.priceUnit,
    this.discountPercent = 0.0,
    required this.lineTotal,
    this.cuttingOption,
    this.packagingOptions = const [],
    this.excludedParts = const [],
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        quantity,
        priceUnit,
        discountPercent,
        lineTotal,
        cuttingOption,
        packagingOptions,
        excludedParts,
        notes,
      ];
}

class CartEntity extends Equatable {
  final int id;
  final String status;
  final List<CartLineEntity> lines;
  final double subtotal;
  final double total;
  final int itemCount;

  const CartEntity({
    required this.id,
    required this.status,
    this.lines = const [],
    this.subtotal = 0.0,
    this.total = 0.0,
    this.itemCount = 0,
  });

  bool get isEmpty => lines.isEmpty;
  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [id, status, lines, subtotal, total, itemCount];
}
