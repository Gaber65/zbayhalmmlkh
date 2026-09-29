import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/core/config/app_config.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Equatable {
  final int id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'name_ar')
  final String? nameAr;

  @JsonKey(name: 'name_en')
  final String? nameEn;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'weight')
  final String? weight;

  @JsonKey(defaultValue: 0.0)
  final double price;

  @JsonKey(name: 'selling_price')
  final double? sellingPrice;

  @JsonKey(name: 'offer_price')
  final double? offerPrice;

  @JsonKey(name: 'original_price')
  final double? originalPrice;

  @JsonKey(name: 'is_on_offer', defaultValue: false)
  final bool isOnOffer;

  @JsonKey(name: 'image_url', defaultValue: '')
  final String imageUrl;

  @JsonKey(name: 'main_image_url')
  final String? mainImageUrl;

  @JsonKey(name: 'discount_tag')
  final String? discountTag;

  @JsonKey(name: 'is_offer', defaultValue: false)
  final bool isOffer;

  @JsonKey(name: 'is_best_seller', defaultValue: false)
  final bool isBestSeller;

  @JsonKey(name: 'is_available', defaultValue: true)
  final bool isAvailable;

  @JsonKey(name: 'stock_quantity')
  final double? stockQuantity;

  @JsonKey(name: 'loyalty_points')
  final int? loyaltyPoints;

  @JsonKey(name: 'cutting_options')
  final List<dynamic>? cuttingOptions;

  @JsonKey(name: 'packaging_options')
  final List<dynamic>? packagingOptions;

  @JsonKey(name: 'excluded_parts')
  final List<dynamic>? excludedParts;

  @JsonKey(name: 'sku')
  final String? sku;

  @JsonKey(name: 'barcode')
  final String? barcode;

  @JsonKey(name: 'purchase_price')
  final double? purchasePrice;

  @JsonKey(name: 'profit')
  final double? profit;

  @JsonKey(name: 'profit_percentage')
  final double? profitPercentage;

  @JsonKey(name: 'discount_type')
  final String? discountType;

  @JsonKey(name: 'discount_value')
  final double? discountValue;

  @JsonKey(name: 'offer_start_date')
  final String? offerStartDate;

  @JsonKey(name: 'offer_end_date')
  final String? offerEndDate;

  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;

  @JsonKey(name: 'active', defaultValue: true)
  final bool active;

  @JsonKey(name: 'minimum_stock')
  final double? minimumStock;

  @JsonKey(name: 'preparation_time')
  final double? preparationTime;

  @JsonKey(name: 'category_id')
  final dynamic categoryId;

  @JsonKey(name: 'category_name')
  final String? categoryName;

  @JsonKey(name: 'images')
  final List<dynamic>? images;

  @JsonKey(name: 'has_sizes', defaultValue: false)
  final bool hasSizes;

  @JsonKey(name: 'sizes')
  final List<dynamic>? sizes;

  @JsonKey(name: 'calories')
  final int? calories;

  const ProductModel({
    required this.id,
    this.name,
    this.nameAr,
    this.nameEn,
    this.description,
    this.sku,
    this.barcode,
    this.weight,
    this.price = 0.0,
    this.purchasePrice,
    this.sellingPrice,
    this.offerPrice,
    this.originalPrice,
    this.profit,
    this.profitPercentage,
    this.discountType,
    this.discountValue,
    this.offerStartDate,
    this.offerEndDate,
    this.isOnOffer = false,
    this.imageUrl = '',
    this.mainImageUrl,
    this.discountTag,
    this.isOffer = false,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.isAvailable = true,
    this.active = true,
    this.stockQuantity,
    this.minimumStock,
    this.preparationTime,
    this.categoryId,
    this.categoryName,
    this.loyaltyPoints,
    this.cuttingOptions,
    this.packagingOptions,
    this.excludedParts,
    this.images,
    this.hasSizes = false,
    this.sizes,
    this.calories,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final normalizedJson = Map<String, dynamic>.from(json);

    // Normalize boolean falsy values from Odoo (e.g. barcode: false, offer_start_date: false)
    for (final key in [
      'name',
      'name_ar',
      'name_en',
      'description',
      'sku',
      'barcode',
      'discount_type',
      'offer_start_date',
      'offer_end_date',
      'category_name',
      'main_image',
      'main_image_url',
      'image_url',
    ]) {
      if (normalizedJson[key] is bool) {
        normalizedJson[key] = null;
      }
    }

    // Normalize name
    if (json['name'] != null && json['name'] is! bool) {
      normalizedJson['name'] = json['name'].toString();
    } else if (json['title'] != null && json['title'] is! bool) {
      normalizedJson['name'] = json['title'].toString();
    }

    // Normalize weight
    if (json['weight'] != null) {
      normalizedJson['weight'] = json['weight'].toString();
    } else if (json['description'] != null) {
      normalizedJson['weight'] = json['description'].toString();
    }

    // Normalize image URL
    final rawImage = json['image_url'] ?? json['main_image_url'] ?? json['main_image'];
    String imgUrl = rawImage?.toString() ?? '';
    if (imgUrl.isNotEmpty && !imgUrl.startsWith('http') && !imgUrl.startsWith('data:')) {
      final base = AppConfig.baseUrl.endsWith('/')
          ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
          : AppConfig.baseUrl;
      final path = imgUrl.startsWith('/') ? imgUrl : '/$imgUrl';
      imgUrl = '$base$path';
    }
    normalizedJson['image_url'] = imgUrl;

    // Normalize price
    final sellingPrice = (json['selling_price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0;
    final offerPrice = (json['offer_price'] as num?)?.toDouble() ?? 0.0;
    final isOnOffer = json['is_on_offer'] as bool? ?? false;

    if (json['price'] == null || json['price'] == 0) {
      normalizedJson['price'] =
          isOnOffer && offerPrice > 0 ? offerPrice : sellingPrice;
    }

    if (json['original_price'] == null && isOnOffer && sellingPrice > 0) {
      normalizedJson['original_price'] = sellingPrice;
    }

    if (json['is_on_offer'] != null) {
      normalizedJson['is_offer'] = json['is_on_offer'];
    }

    return _$ProductModelFromJson(normalizedJson);
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  /// Parse option list from backend — backend returns [{id, name}] objects
  static List<ProductOption> _parseOptions(List<dynamic>? raw) {
    if (raw == null) return [];
    return raw.map((e) {
      if (e is Map) {
        return ProductOption.fromMap(Map<String, dynamic>.from(e));
      }
      return null;
    }).whereType<ProductOption>().toList();
  }

  /// Parse gallery image URLs
  static List<String> _parseGalleryImages(List<dynamic>? raw) {
    if (raw == null) return [];
    return raw.map((e) {
      if (e is Map) {
        return (e['image_url'] ?? e['image'] ?? '').toString();
      }
      return e.toString();
    }).where((url) => url.isNotEmpty).toList();
  }

  /// Parse sizes from backend
  static List<ProductSize> _parseSizes(List<dynamic>? raw) {
    if (raw == null) return [];
    return raw.map((e) {
      if (e is Map) {
        return ProductSize.fromMap(Map<String, dynamic>.from(e));
      }
      return null;
    }).whereType<ProductSize>().toList();
  }

  Product toDomain() {
    final effectiveSellingPrice =
        sellingPrice ?? (isOnOffer ? offerPrice ?? 0.0 : price);

    int? parsedCatId;
    String? parsedCatName = categoryName;
    if (categoryId is int) {
      parsedCatId = categoryId;
    } else if (categoryId is Map) {
      parsedCatId = (categoryId['id'] as num?)?.toInt();
      parsedCatName ??= categoryId['name']?.toString();
    } else if (categoryId is num) {
      parsedCatId = categoryId.toInt();
    }

    final parsedWeight = double.tryParse(weight ?? '');

    return Product(
      id: id,
      title: name ?? '',
      titleAr: nameAr,
      titleEn: nameEn,
      subtitle: weight ?? description ?? '',
      description: description,
      sku: sku,
      barcode: barcode,
      price: effectiveSellingPrice,
      purchasePrice: purchasePrice,
      originalPrice: originalPrice,
      offerPrice: offerPrice,
      profit: profit,
      profitPercentage: profitPercentage,
      discountType: discountType,
      discountValue: discountValue,
      offerStartDate: offerStartDate,
      offerEndDate: offerEndDate,
      isOnOffer: isOnOffer,
      imageUrl: mainImageUrl ?? imageUrl,
      discountTag: discountTag,
      isOffer: isOffer,
      isFeatured: isFeatured,
      isBestSeller: isBestSeller,
      isAvailable: isAvailable,
      active: active,
      stockQuantity: stockQuantity,
      minimumStock: minimumStock,
      weightKg: parsedWeight,
      preparationTimeMin: preparationTime,
      categoryId: parsedCatId,
      categoryName: parsedCatName,
      loyaltyPoints: loyaltyPoints,
      hasSizes: hasSizes || (sizes != null && sizes!.isNotEmpty),
      sizes: _parseSizes(sizes),
      calories: calories ?? 0,
      cuttingOptions: _parseOptions(cuttingOptions),
      packagingOptions: _parseOptions(packagingOptions),
      excludedParts: _parseOptions(excludedParts),
      galleryImages: _parseGalleryImages(images),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sku,
        barcode,
        price,
        sellingPrice,
        purchasePrice,
        offerPrice,
        isOnOffer,
        imageUrl,
        isOffer,
        isFeatured,
        isBestSeller,
        isAvailable,
        active,
        stockQuantity,
        minimumStock,
        categoryId,
        cuttingOptions,
        packagingOptions,
        excludedParts,
      ];
}
