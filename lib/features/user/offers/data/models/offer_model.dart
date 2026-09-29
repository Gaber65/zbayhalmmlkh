import '../../../catalog/data/models/product_model.dart';
import '../../domain/entities/offer_entity.dart';

class OfferModel {
  final int id;
  final String name;
  final String? subtitle;
  final String? description;
  final String? bannerImageUrl;
  final String discountType;
  final double discountValue;
  final String badgeText;
  final List<ProductModel> products;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final List<int> productIds;

  OfferModel({
    required this.id,
    required this.name,
    this.subtitle,
    this.description,
    this.bannerImageUrl,
    required this.discountType,
    required this.discountValue,
    required this.badgeText,
    this.products = const [],
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.productIds = const [],
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    var rawProducts = json['products'];
    List<ProductModel> productList = [];
    if (rawProducts is List) {
      productList = rawProducts
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    List<int> pIds = [];
    if (json['product_ids'] is List) {
      pIds = (json['product_ids'] as List)
          .map((e) => (e as num).toInt())
          .toList();
    } else if (productList.isNotEmpty) {
      pIds = productList.map((p) => p.id).toList();
    }

    return OfferModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      bannerImageUrl: json['banner_image_url']?.toString(),
      discountType: json['discount_type']?.toString() ?? 'percentage',
      discountValue: (json['discount_value'] is num)
          ? (json['discount_value'] as num).toDouble()
          : double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      badgeText: json['badge_text']?.toString() ?? '',
      products: productList,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      isActive: json['is_active'] == true || json['active'] == true || (json['is_active'] == null && json['active'] == null),
      productIds: pIds,
    );
  }

  OfferEntity toDomain() => OfferEntity(
        id: id,
        name: name,
        subtitle: subtitle,
        description: description,
        bannerImageUrl: bannerImageUrl,
        discountType: discountType,
        discountValue: discountValue,
        badgeText: badgeText,
        products: products.map((p) => p.toDomain()).toList(),
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
        productIds: productIds,
      );
}
