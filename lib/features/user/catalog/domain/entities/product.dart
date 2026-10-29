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
  final String? portionType; // 'full', 'half', 'quarter'
  final String? weightRange;
  final double? minWeight;
  final double? maxWeight;
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
    this.portionType,
    this.weightRange,
    this.minWeight,
    this.maxWeight,
    required this.price,
    this.calories = 0,
    this.loyaltyPoints = 0,
    this.pointsPrice = 0,
    this.isDefault = false,
    this.sequence = 0,
  });

  /// Intelligently derive the displayed weight range (e.g. "11-12 كجم")
  String get effectiveWeightRange {
    if (weightRange != null && weightRange!.isNotEmpty) {
      return weightRange!;
    }
    if (subTitle != null && subTitle!.contains('كجم')) {
      return subTitle!;
    }
    final lowerName = name.toLowerCase();
    if (lowerName.contains('فاخر')) return '16 - 17 كجم تقريباً';
    if (lowerName.contains('وسط') && lowerName.contains('هرفي')) return '13 - 14 كجم تقريباً';
    if (lowerName.contains('صغير') || lowerName.contains('هرفي')) return '11 - 12 كجم تقريباً';
    if (lowerName.contains('جذع وسط')) return '18 - 20 كجم تقريباً';
    if (lowerName.contains('جذع') || lowerName.contains('جبر') || lowerName.contains('ناهي')) return '21 - 23 كجم تقريباً';
    if (lowerName.contains('كبير') || lowerName.contains('ثني')) return '24 - 27 كجم تقريباً';
    return '11 - 12 كجم تقريباً';
  }

  factory ProductSize.fromMap(Map<String, dynamic> map) {
    return ProductSize(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      subTitle: map['sub_title'] as String? ?? map['subTitle'] as String?,
      portionType: map['portion_type'] as String? ?? map['portionType'] as String?,
      weightRange: map['weight_range'] as String? ?? map['weightRange'] as String? ?? (map['weight']?.toString()),
      minWeight: (map['min_weight'] as num?)?.toDouble() ?? (map['minWeight'] as num?)?.toDouble(),
      maxWeight: (map['max_weight'] as num?)?.toDouble() ?? (map['maxWeight'] as num?)?.toDouble(),
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
    'portion_type': portionType,
    'weight_range': weightRange,
    'min_weight': minWeight,
    'max_weight': maxWeight,
    'price': price,
    'calories': calories,
    'loyalty_points': loyaltyPoints,
    'points_price': pointsPrice,
    'is_default': isDefault,
    'sequence': sequence,
  };

  @override
  List<Object?> get props => [id, name, subTitle, portionType, weightRange, minWeight, maxWeight, price, calories, loyaltyPoints, pointsPrice, isDefault, sequence];
}

/// Represents an API-driven carcass portion breakdown (كامل, نصف, ربع)
class ProductPortion extends Equatable {
  final String type; // 'full', 'half', 'quarter'
  final String name; // 'كامل', 'نصف', 'ربع'
  final String title;
  final String subtitle;
  final String imageUrl;
  final double startingPrice;
  final int sizeCount;

  const ProductPortion({
    required this.type,
    required this.name,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.startingPrice,
    this.sizeCount = 0,
  });

  factory ProductPortion.fromMap(Map<String, dynamic> map) {
    return ProductPortion(
      type: map['type'] as String? ?? 'full',
      name: map['name'] as String? ?? 'كامل',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      startingPrice: (map['starting_price'] as num?)?.toDouble() ?? 0.0,
      sizeCount: (map['size_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'name': name,
    'title': title,
    'subtitle': subtitle,
    'image_url': imageUrl,
    'starting_price': startingPrice,
    'size_count': sizeCount,
  };

  @override
  List<Object?> get props => [type, name, title, subtitle, imageUrl, startingPrice, sizeCount];
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
  final bool isCarcass;
  final List<ProductPortion> portions;
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
    this.isCarcass = false,
    this.portions = const [],
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

  /// Real API-driven carcass portions synchronized strictly with assigned sizes
  List<ProductPortion> get effectivePortions {
    if (portions.isNotEmpty) {
      final filtered = portions
          .where(
            (p) =>
                p.sizeCount > 0 ||
                sizes.any((s) => (s.portionType ?? 'full') == p.type),
          )
          .toList();
      if (filtered.isNotEmpty) return filtered;
    }
    if (!hasSizes || sizes.isEmpty) return const [];

    final fullSizes =
        sizes.where((s) => (s.portionType ?? 'full') == 'full').toList();
    final halfSizes = sizes.where((s) => s.portionType == 'half').toList();
    final quarterSizes =
        sizes.where((s) => s.portionType == 'quarter').toList();

    final result = <ProductPortion>[];
    if (fullSizes.isNotEmpty) {
      result.add(
        ProductPortion(
          type: 'full',
          name: 'كامل',
          title: '$title كامل',
          subtitle: 'ذبيحة كاملة مجهزة بالكامل',
          imageUrl: imageUrl,
          startingPrice: fullSizes.first.price,
          sizeCount: fullSizes.length,
        ),
      );
    }
    if (halfSizes.isNotEmpty) {
      result.add(
        ProductPortion(
          type: 'half',
          name: 'نصف',
          title: 'نصف $title',
          subtitle: 'نصف ذبيحة طازج مقسوم بالطول',
          imageUrl: imageUrl,
          startingPrice: halfSizes.first.price,
          sizeCount: halfSizes.length,
        ),
      );
    }
    if (quarterSizes.isNotEmpty) {
      result.add(
        ProductPortion(
          type: 'quarter',
          name: 'ربع',
          title: 'ربع $title',
          subtitle: 'ربع متكامل (كتف أو فخذ مع ضلوع)',
          imageUrl: imageUrl,
          startingPrice: quarterSizes.first.price,
          sizeCount: quarterSizes.length,
        ),
      );
    }
    return result;
  }

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
        sizes,
        isCarcass,
        portions,
        cuttingOptions,
        packagingOptions,
        excludedParts,
        galleryImages,
      ];
}
