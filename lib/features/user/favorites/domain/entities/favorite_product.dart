import 'package:equatable/equatable.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';

class FavoriteProduct extends Equatable {
  final int id;
  final String title;
  final String? titleAr;
  final String? titleEn;
  final String subtitle;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String? discountTag;
  final bool isAvailable;
  final DateTime addedAt;

  FavoriteProduct({
    required this.id,
    required this.title,
    this.titleAr,
    this.titleEn,
    required this.subtitle,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.discountTag,
    this.isAvailable = true,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  factory FavoriteProduct.fromProduct(Product product) {
    return FavoriteProduct(
      id: product.id,
      title: product.title,
      titleAr: product.titleAr,
      titleEn: product.titleEn,
      subtitle: product.subtitle,
      price: product.price,
      originalPrice: product.originalPrice,
      imageUrl: product.imageUrl,
      discountTag: product.discountTag,
      isAvailable: product.isAvailable,
      addedAt: DateTime.now(),
    );
  }

  factory FavoriteProduct.fromMap(Map<String, dynamic> map) {
    final priceRaw = map['price'] ?? map['selling_price'] ?? 0;
    final origPriceRaw = map['original_price'] ?? map['offer_price'];
    return FavoriteProduct(
      id: (map['id'] ?? map['product_id'] as num?)?.toInt() ?? 0,
      title: (map['title'] ?? map['name'] as String?) ?? '',
      titleAr: map['title_ar'] as String?,
      titleEn: map['title_en'] as String?,
      subtitle: (map['subtitle'] ?? map['sku'] as String?) ?? '',
      price: (priceRaw is num) ? priceRaw.toDouble() : double.tryParse(priceRaw.toString()) ?? 0.0,
      originalPrice: origPriceRaw != null
          ? ((origPriceRaw is num) ? origPriceRaw.toDouble() : double.tryParse(origPriceRaw.toString()))
          : null,
      imageUrl: (map['image_url'] ?? map['main_image_url'] ?? map['main_image'] ?? '') as String,
      discountTag: map['discount_tag'] as String?,
      isAvailable: map['is_available'] as bool? ?? true,
      addedAt: map['added_at'] != null
          ? DateTime.tryParse(map['added_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'title_en': titleEn,
      'subtitle': subtitle,
      'price': price,
      'original_price': originalPrice,
      'image_url': imageUrl,
      'discount_tag': discountTag,
      'is_available': isAvailable,
      'added_at': addedAt.toIso8601String(),
    };
  }

  Product toProduct() {
    return Product(
      id: id,
      title: title,
      titleAr: titleAr,
      titleEn: titleEn,
      subtitle: subtitle,
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      discountTag: discountTag,
      isAvailable: isAvailable,
    );
  }

  @override
  List<Object?> get props => [id, title, subtitle, price, imageUrl, isAvailable];
}
