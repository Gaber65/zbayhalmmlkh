import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';

class OfferEntity extends Equatable {
  final int id;
  final String name;
  final String? subtitle;
  final String? description;
  final String? bannerImageUrl;
  final String discountType;
  final double discountValue;
  final String badgeText;
  final List<Product> products;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final List<int> productIds;

  const OfferEntity({
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

  OfferEntity copyWith({
    int? id,
    String? name,
    String? subtitle,
    String? description,
    String? bannerImageUrl,
    String? discountType,
    double? discountValue,
    String? badgeText,
    List<Product>? products,
    String? startDate,
    String? endDate,
    bool? isActive,
    List<int>? productIds,
  }) {
    return OfferEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      badgeText: badgeText ?? this.badgeText,
      products: products ?? this.products,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      productIds: productIds ?? this.productIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        subtitle,
        description,
        bannerImageUrl,
        discountType,
        discountValue,
        badgeText,
        products,
        startDate,
        endDate,
        isActive,
        productIds,
      ];
}
