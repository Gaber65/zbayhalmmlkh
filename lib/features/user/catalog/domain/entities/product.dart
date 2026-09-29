import 'package:equatable/equatable.dart';

/// Represents a single selectable option (cutting, packaging, excluded part)
class ProductOption extends Equatable {
  final int id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final double? extraPrice;

  const ProductOption({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.extraPrice,
  });

  factory ProductOption.fromMap(Map<String, dynamic> map) {
    return ProductOption(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String?,
      nameEn: map['name_en'] as String?,
      extraPrice: (map['extra_price'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, nameAr, nameEn, extraPrice];
}

class ProductSize extends Equatable {
  final int id;
  final String name;
  final String? subTitle;
  final double price;
  final int calories;
  final int loyaltyPoints;
  final int pointsPrice;
  final bool isDefault;
  final int sequence;

  const ProductSize({
    required this.id,
    required this.name,
    this.subTitle,
    required this.price,
    this.calories = 0,
    this.loyaltyPoints = 0,
    this.pointsPrice = 0,
    this.isDefault = false,
    this.sequence = 0,
  });

  factory ProductSize.fromMap(Map<String, dynamic> map) {
    return ProductSize(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      subTitle: map['sub_title'] as String? ?? map['subTitle'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      loyaltyPoints: (map['loyalty_points'] as num?)?.toInt() ?? (map['loyaltyPoints'] as num?)?.toInt() ?? 0,
      pointsPrice: (map['points_price'] as num?)?.toInt() ?? (map['pointsPrice'] as num?)?.toInt() ?? 0,
      isDefault: map['is_default'] as bool? ?? map['isDefault'] as bool? ?? false,
      sequence: (map['sequence'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sub_title': subTitle,
    'price': price,
    'calories': calories,
    'loyalty_points': loyaltyPoints,
    'points_price': pointsPrice,
    'is_default': isDefault,
    'sequence': sequence,
  };

  @override
  List<Object?> get props => [id, name, subTitle, price, calories, loyaltyPoints, pointsPrice, isDefault, sequence];
}

class Product extends Equatable {
  final int id;
  final String title;
  final String? titleAr;
  final String? titleEn;
  final String subtitle;
  final String? description;
  final String? sku;
  final String? barcode;
  final double price;
  final double? purchasePrice;
  final double? originalPrice;
  final double? offerPrice;
  final double? profit;
  final double? profitPercentage;
  final String? discountType;
  final double? discountValue;
  final String? offerStartDate;
  final String? offerEndDate;
  final bool isOnOffer;
  final String imageUrl;
  final String? discountTag;
  final bool isOffer;
  final bool isFeatured;
  final bool isBestSeller;
  final bool isAvailable;
  final bool active;
  final double? stockQuantity;
  final double? minimumStock;
  final double? weightKg;
  final double? preparationTimeMin;
  final int? categoryId;
  final String? categoryName;
  final int? loyaltyPoints;
  final int calories;
  final bool hasSizes;
  final List<ProductSize> sizes;
  final List<ProductOption> cuttingOptions;
  final List<ProductOption> packagingOptions;
  final List<ProductOption> excludedParts;
  final List<String> galleryImages;

  const Product({
    required this.id,
    required this.title,
    this.titleAr,
    this.titleEn,
    required this.subtitle,
    this.description,
    this.sku,
    this.barcode,
    required this.price,
    this.purchasePrice,
    this.originalPrice,
    this.offerPrice,
    this.profit,
    this.profitPercentage,
    this.discountType,
    this.discountValue,
    this.offerStartDate,
    this.offerEndDate,
    this.isOnOffer = false,
    required this.imageUrl,
    this.discountTag,
    this.isOffer = false,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.isAvailable = true,
    this.active = true,
    this.stockQuantity,
    this.minimumStock,
    this.weightKg,
    this.preparationTimeMin,
    this.categoryId,
    this.categoryName,
    this.loyaltyPoints,
    this.calories = 0,
    this.hasSizes = false,
    this.sizes = const [],
    this.cuttingOptions = const [],
    this.packagingOptions = const [],
    this.excludedParts = const [],
    this.galleryImages = const [],
  });

  /// The effective price to display (offer price if on offer, else regular price)
  double get displayPrice => (isOnOffer && offerPrice != null && offerPrice! > 0)
      ? offerPrice!
      : price;

  /// Saving amount if on offer
  double? get savingAmount =>
      (isOnOffer && offerPrice != null && price > 0 && price > offerPrice!)
          ? (price - offerPrice!)
          : null;

  /// Whether current stock is low (below minimumStock threshold)
  bool get isLowStock =>
      minimumStock != null &&
      minimumStock! > 0 &&
      (stockQuantity ?? 0) <= minimumStock!;

  /// Calculated profit amount (sellingPrice - purchasePrice)
  double get calculatedProfit {
    if (profit != null) return profit!;
    if (purchasePrice != null && purchasePrice! > 0) {
      final effectiveSelling = (isOnOffer && offerPrice != null && offerPrice! > 0) ? offerPrice! : price;
      return effectiveSelling - purchasePrice!;
    }
    return 0.0;
  }

  /// Calculated profit margin percentage
  double get calculatedProfitPercentage {
    if (profitPercentage != null) return profitPercentage!;
    if (purchasePrice != null && purchasePrice! > 0) {
      return (calculatedProfit / purchasePrice!) * 100;
    }
    return 0.0;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleAr,
        titleEn,
        subtitle,
        description,
        sku,
        barcode,
        price,
        purchasePrice,
        originalPrice,
        offerPrice,
        profit,
        profitPercentage,
        discountType,
        discountValue,
        offerStartDate,
        offerEndDate,
        isOnOffer,
        imageUrl,
        discountTag,
        isOffer,
        isFeatured,
        isBestSeller,
        isAvailable,
        active,
        stockQuantity,
        minimumStock,
        weightKg,
        preparationTimeMin,
        categoryId,
        categoryName,
        loyaltyPoints,
        cuttingOptions,
        packagingOptions,
        excludedParts,
        galleryImages,
      ];
}
