import 'package:dhabayih_lmamlaka/features/user/cart/domain/entities/cart.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';

class CartLineModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final double quantity;
  final double priceUnit;
  final double discountPercent;
  final double lineTotal;
  final int? sizeId;
  final String? sizeName;
  final double sizePrice;
  final double cuttingPrice;
  final double packagingPrice;
  final Map<String, dynamic>? cuttingOption;
  final List<dynamic> packagingOptions;
  final List<dynamic> excludedParts;
  final String? notes;

  CartLineModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.priceUnit,
    this.discountPercent = 0.0,
    required this.lineTotal,
    this.sizeId,
    this.sizeName,
    this.sizePrice = 0.0,
    this.cuttingPrice = 0.0,
    this.packagingPrice = 0.0,
    this.cuttingOption,
    this.packagingOptions = const [],
    this.excludedParts = const [],
    this.notes,
  });

  factory CartLineModel.fromJson(Map<String, dynamic> json) {
    final sizeMap = json['size'] is Map<String, dynamic>
        ? json['size'] as Map<String, dynamic>
        : null;
    final parsedSizeId = (json['size_id'] as num?)?.toInt() ??
        (sizeMap?['id'] as num?)?.toInt();
    final parsedSizeName = json['size_name'] as String? ??
        sizeMap?['name'] as String?;
    final parsedSizePrice = (json['size_price'] as num?)?.toDouble() ??
        (sizeMap?['price'] as num?)?.toDouble() ??
        0.0;

    return CartLineModel(
      id: (json['id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      productName: json['product_name'] as String? ?? '',
      productImageUrl: json['product_image_url'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      priceUnit: (json['price_unit'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0.0,
      sizeId: parsedSizeId != null && parsedSizeId > 0 ? parsedSizeId : null,
      sizeName: parsedSizeName != null && parsedSizeName.trim().isNotEmpty
          ? parsedSizeName
          : null,
      sizePrice: parsedSizePrice,
      cuttingPrice: (json['cutting_price'] as num?)?.toDouble() ?? 0.0,
      packagingPrice: (json['packaging_price'] as num?)?.toDouble() ?? 0.0,
      cuttingOption: json['cutting_option'] as Map<String, dynamic>?,
      packagingOptions: json['packaging_options'] as List<dynamic>? ?? [],
      excludedParts: json['excluded_parts'] as List<dynamic>? ?? [],
      notes: json['notes'] as String?,
    );
  }

  static ProductOption? _toOption(Map<String, dynamic>? map) {
    if (map == null) return null;
    return ProductOption(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String?,
      nameEn: map['name_en'] as String?,
      extraPrice: (map['extra_price'] as num?)?.toDouble() ??
          (map['price'] as num?)?.toDouble(),
    );
  }

  static List<ProductOption> _toOptionList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => ProductOption(
            id: (e['id'] as num).toInt(),
            name: e['name'] as String? ?? '',
            nameAr: e['name_ar'] as String?,
            nameEn: e['name_en'] as String?,
            extraPrice: (e['extra_price'] as num?)?.toDouble() ??
                (e['price'] as num?)?.toDouble(),
          ),
        )
        .toList();
  }

  CartLineEntity toDomain() {
    final cutOpt = _toOption(cuttingOption);
    final pkgOpts = _toOptionList(packagingOptions);
    final resolvedCuttingPrice = cuttingPrice > 0
        ? cuttingPrice
        : (cutOpt?.extraPrice ?? 0.0);
    final resolvedPackagingPrice = packagingPrice > 0
        ? packagingPrice
        : pkgOpts.fold<double>(0.0, (sum, p) => sum + (p.extraPrice ?? 0.0));

    return CartLineEntity(
      id: id,
      productId: productId,
      productName: productName,
      productImageUrl: productImageUrl,
      quantity: quantity,
      priceUnit: priceUnit,
      discountPercent: discountPercent,
      lineTotal: lineTotal,
      sizeId: sizeId,
      sizeName: sizeName,
      sizePrice: sizePrice,
      cuttingPrice: resolvedCuttingPrice,
      packagingPrice: resolvedPackagingPrice,
      cuttingOption: cutOpt,
      packagingOptions: pkgOpts,
      excludedParts: _toOptionList(excludedParts),
      notes: notes,
    );
  }
}

class CartModel {
  final int id;
  final String status;
  final List<CartLineModel> lines;
  final double subtotal;
  final double total;

  CartModel({
    required this.id,
    required this.status,
    this.lines = const [],
    this.subtotal = 0.0,
    this.total = 0.0,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? [];
    return CartModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'active',
      lines: rawLines
          .whereType<Map<String, dynamic>>()
          .map((e) => CartLineModel.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      total: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  CartEntity toDomain() => CartEntity(
    id: id,
    status: status,
    lines: lines.map((l) => l.toDomain()).toList(),
    subtotal: subtotal,
    total: total,
    itemCount: lines.length,
  );
}
