import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../../catalog/data/models/category_model.dart';
import 'package:dhabayih_lmamlaka/features/user/offers/data/models/offer_model.dart';
import '../../domain/entities/home_data.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../../../../core/config/app_config.dart';

part 'home_response_model.g.dart';

@JsonSerializable()
class HomeResponseModel extends Equatable {
  final bool success;
  final String message;
  final int code;
  final HomeDataModel data;

  const HomeResponseModel({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) => _$HomeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeResponseModelToJson(this);

  @override
  List<Object?> get props => [success, message, code, data];
}

@JsonSerializable()
class HomeDataModel extends Equatable {
  @JsonKey(name: 'delivery_location', fromJson: _parseDeliveryLocation)
  final String? deliveryLocation;

  static String? _parseDeliveryLocation(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is Map) {
      return json['name'] as String? ?? json['address'] as String?;
    }
    return null;
  }
  
  @JsonKey(name: 'user_highlight')
  final UserHighlightModel? userHighlight;
  
  @JsonKey(defaultValue: [])
  final List<BannerModel> banners;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<OfferModel> offers;
  
  @JsonKey(defaultValue: [])
  final List<CategoryModel> categories;
  
  @JsonKey(name: 'featured_products', defaultValue: [])
  final List<HomeProductModel> featuredProducts;
  
  @JsonKey(name: 'best_sellers', defaultValue: [])
  final List<HomeProductModel> bestSellers;
  
  @JsonKey(name: 'recommended_products', defaultValue: [])
  final List<HomeProductModel> recommendedProducts;

  @JsonKey(name: 'jabin_highlight', defaultValue: [])
  final List<JabinHighlightModel> jabinHighlight;

  const HomeDataModel({
    this.deliveryLocation,
    this.userHighlight,
    this.banners = const [],
    this.offers = const [],
    this.categories = const [],
    this.featuredProducts = const [],
    this.bestSellers = const [],
    this.recommendedProducts = const [],
    this.jabinHighlight = const [],
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    final base = _$HomeDataModelFromJson(json);
    List<OfferModel> parsedOffers = [];
    if (json['offers'] is List) {
      parsedOffers = (json['offers'] as List)
          .whereType<Map>()
          .map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return HomeDataModel(
      deliveryLocation: base.deliveryLocation,
      userHighlight: base.userHighlight,
      banners: base.banners,
      offers: parsedOffers,
      categories: base.categories,
      featuredProducts: base.featuredProducts,
      bestSellers: base.bestSellers,
      recommendedProducts: base.recommendedProducts,
      jabinHighlight: base.jabinHighlight,
    );
  }

  Map<String, dynamic> toJson() => _$HomeDataModelToJson(this);
  
  HomeData toDomain() {
    return HomeData(
      deliveryLocation: deliveryLocation,
      userHighlight: userHighlight?.toDomain(),
      banners: banners.map((e) => e.toDomain()).toList(),
      offers: offers.map((e) => e.toDomain()).toList(),
      categories: categories.map((e) => e.toDomain()).toList(),
      featuredProducts: featuredProducts.map((e) => e.toDomain()).toList(),
      bestSellers: bestSellers.map((e) => e.toDomain()).toList(),
      recommendedProducts: recommendedProducts.map((e) => e.toDomain()).toList(),
      jabinHighlight: jabinHighlight.map((e) => e.toDomain()).toList(),
    );
  }

  @override
  List<Object?> get props => [
        deliveryLocation,
        userHighlight,
        banners,
        offers,
        categories,
        featuredProducts,
        bestSellers,
        recommendedProducts,
        jabinHighlight,
      ];
}

@JsonSerializable()
class UserHighlightModel extends Equatable {
  final int id;
  final String? name;
  final String? email;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(defaultValue: 0.0)
  final double balance;
  @JsonKey(name: 'active_cart')
  final ActiveCartModel? activeCart;

  const UserHighlightModel({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    this.balance = 0.0,
    this.activeCart,
  });

  factory UserHighlightModel.fromJson(Map<String, dynamic> json) => _$UserHighlightModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserHighlightModelToJson(this);

  UserHighlight toDomain() {
    return UserHighlight(
      id: id,
      name: name ?? '',
      email: email ?? '',
      avatarUrl: avatarUrl ?? '',
      balance: balance,
      activeCart: activeCart?.toDomain(),
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, balance, activeCart];
}

@JsonSerializable()
class ActiveCartModel extends Equatable {
  final int id;
  final String status;
  @JsonKey(name: 'line_count', defaultValue: 0)
  final int lineCount;

  const ActiveCartModel({
    required this.id,
    required this.status,
    this.lineCount = 0,
  });

  factory ActiveCartModel.fromJson(Map<String, dynamic> json) => _$ActiveCartModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveCartModelToJson(this);
  
  ActiveCart toDomain() {
    return ActiveCart(
      id: id,
      status: status,
      lineCount: lineCount,
    );
  }

  @override
  List<Object?> get props => [id, status, lineCount];
}

@JsonSerializable()
class BannerModel extends Equatable {
  final int id;
  final String name;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'banner_type')
  final String? bannerType;
  @JsonKey(name: 'offer_id')
  final int? offerId;
  @JsonKey(name: 'deep_link')
  final String? deepLink;

  const BannerModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bannerType,
    this.offerId,
    this.deepLink,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      bannerType: json['banner_type']?.toString(),
      offerId: json['offer_id'] is int
          ? json['offer_id']
          : int.tryParse(json['offer_id']?.toString() ?? ''),
      deepLink: json['deep_link']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
        'banner_type': bannerType,
        'offer_id': offerId,
        'deep_link': deepLink,
      };

  BannerEntity toDomain() {
    return BannerEntity(
      id: id,
      name: name,
      imageUrl: _buildImageUrl(imageUrl),
      bannerType: bannerType,
      offerId: offerId,
      deepLink: deepLink,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, bannerType, offerId, deepLink];
}

@JsonSerializable()
class HomeProductModel extends Equatable {
  final int id;
  final String? name;
  final String? description;
  @JsonKey(name: 'selling_price')
  final double? sellingPrice;
  @JsonKey(name: 'offer_price')
  final double? offerPrice;
  @JsonKey(name: 'is_on_offer', defaultValue: false)
  final bool isOnOffer;
  @JsonKey(name: 'is_best_seller', defaultValue: false)
  final bool isBestSeller;
  @JsonKey(name: 'main_image_url')
  final String? mainImageUrl;
  @JsonKey(name: 'cutting_options')
  final List<dynamic>? cuttingOptions;
  @JsonKey(name: 'packaging_options')
  final List<dynamic>? packagingOptions;
  @JsonKey(name: 'excluded_parts')
  final List<dynamic>? excludedParts;

  const HomeProductModel({
    required this.id,
    this.name,
    this.description,
    this.sellingPrice,
    this.offerPrice,
    this.isOnOffer = false,
    this.isBestSeller = false,
    this.mainImageUrl,
    this.cuttingOptions,
    this.packagingOptions,
    this.excludedParts,
  });

  factory HomeProductModel.fromJson(Map<String, dynamic> json) => _$HomeProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeProductModelToJson(this);

  static List<ProductOption> _parseOptions(List<dynamic>? raw) {
    if (raw == null) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductOption.fromMap(e))
        .toList();
  }

  Product toDomain() {
    return Product(
      id: id,
      title: name ?? '',
      subtitle: description ?? '',
      price: isOnOffer ? (offerPrice ?? sellingPrice ?? 0.0) : (sellingPrice ?? 0.0),
      originalPrice: isOnOffer ? sellingPrice : null,
      imageUrl: _buildImageUrl(mainImageUrl),
      isOffer: isOnOffer,
      isBestSeller: isBestSeller,
      cuttingOptions: _parseOptions(cuttingOptions),
      packagingOptions: _parseOptions(packagingOptions),
      excludedParts: _parseOptions(excludedParts),
    );
  }


  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sellingPrice,
        offerPrice,
        isOnOffer,
        isBestSeller,
        mainImageUrl,
        cuttingOptions,
        packagingOptions,
        excludedParts,
      ];
}

@JsonSerializable()
class JabinHighlightModel extends Equatable {
  final HighlightUserModel user;
  final List<HighlightModel> highlights;

  const JabinHighlightModel({
    required this.user,
    required this.highlights,
  });

  factory JabinHighlightModel.fromJson(Map<String, dynamic> json) => _$JabinHighlightModelFromJson(json);

  Map<String, dynamic> toJson() => _$JabinHighlightModelToJson(this);

  JabinHighlightEntity toDomain() {
    return JabinHighlightEntity(
      user: user.toDomain(),
      highlights: highlights.map((e) => e.toDomain()).toList(),
    );
  }

  @override
  List<Object?> get props => [user, highlights];
}

@JsonSerializable()
class HighlightUserModel extends Equatable {
  final int id;
  final String? name;
  final String? email;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  const HighlightUserModel({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
  });

  factory HighlightUserModel.fromJson(Map<String, dynamic> json) => _$HighlightUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$HighlightUserModelToJson(this);

  HighlightUser toDomain() {
    return HighlightUser(
      id: id,
      name: name ?? '',
      email: email ?? '',
      avatarUrl: _buildImageUrl(avatarUrl),
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}

@JsonSerializable()
class HighlightModel extends Equatable {
  final int id;
  final String? name;
  @JsonKey(name: 'media_type')
  final String? mediaType;
  @JsonKey(name: 'media_url')
  final String? mediaUrl;

  const HighlightModel({
    required this.id,
    this.name,
    this.mediaType,
    this.mediaUrl,
  });

  factory HighlightModel.fromJson(Map<String, dynamic> json) => _$HighlightModelFromJson(json);

  Map<String, dynamic> toJson() => _$HighlightModelToJson(this);

  HighlightEntity toDomain() {
    return HighlightEntity(
      id: id,
      name: name ?? '',
      mediaType: mediaType ?? 'image',
      mediaUrl: _buildImageUrl(mediaUrl),
    );
  }

  @override
  List<Object?> get props => [id, name, mediaType, mediaUrl];
}

String _buildImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http')) return url;
  
  String base = AppConfig.baseUrl;
  if (base.endsWith('/')) {
    base = base.substring(0, base.length - 1);
  }
  
  String path = url;
  if (!path.startsWith('/')) {
    path = '/$path';
  }
  return '$base$path';
}
