// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeResponseModel _$HomeResponseModelFromJson(Map<String, dynamic> json) =>
    HomeResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: (json['code'] as num).toInt(),
      data: HomeDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeResponseModelToJson(HomeResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

HomeDataModel _$HomeDataModelFromJson(Map<String, dynamic> json) =>
    HomeDataModel(
      deliveryLocation: HomeDataModel._parseDeliveryLocation(
        json['delivery_location'],
      ),
      userHighlight: json['user_highlight'] == null
          ? null
          : UserHighlightModel.fromJson(
              json['user_highlight'] as Map<String, dynamic>,
            ),
      banners:
          (json['banners'] as List<dynamic>?)
              ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      featuredProducts:
          (json['featured_products'] as List<dynamic>?)
              ?.map((e) => HomeProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bestSellers:
          (json['best_sellers'] as List<dynamic>?)
              ?.map((e) => HomeProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedProducts:
          (json['recommended_products'] as List<dynamic>?)
              ?.map((e) => HomeProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      jabinHighlight:
          (json['jabin_highlight'] as List<dynamic>?)
              ?.map(
                (e) => JabinHighlightModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$HomeDataModelToJson(HomeDataModel instance) =>
    <String, dynamic>{
      'delivery_location': instance.deliveryLocation,
      'user_highlight': instance.userHighlight,
      'banners': instance.banners,
      'categories': instance.categories,
      'featured_products': instance.featuredProducts,
      'best_sellers': instance.bestSellers,
      'recommended_products': instance.recommendedProducts,
      'jabin_highlight': instance.jabinHighlight,
    };

UserHighlightModel _$UserHighlightModelFromJson(Map<String, dynamic> json) =>
    UserHighlightModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      activeCart: json['active_cart'] == null
          ? null
          : ActiveCartModel.fromJson(
              json['active_cart'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$UserHighlightModelToJson(UserHighlightModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
      'balance': instance.balance,
      'active_cart': instance.activeCart,
    };

ActiveCartModel _$ActiveCartModelFromJson(Map<String, dynamic> json) =>
    ActiveCartModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String,
      lineCount: (json['line_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ActiveCartModelToJson(ActiveCartModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'line_count': instance.lineCount,
    };

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  imageUrl: json['image_url'] as String?,
  bannerType: json['banner_type'] as String?,
  offerId: (json['offer_id'] as num?)?.toInt(),
  deepLink: json['deep_link'] as String?,
);

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image_url': instance.imageUrl,
      'banner_type': instance.bannerType,
      'offer_id': instance.offerId,
      'deep_link': instance.deepLink,
    };

HomeProductModel _$HomeProductModelFromJson(Map<String, dynamic> json) =>
    HomeProductModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      sellingPrice: (json['selling_price'] as num?)?.toDouble(),
      offerPrice: (json['offer_price'] as num?)?.toDouble(),
      isOnOffer: json['is_on_offer'] as bool? ?? false,
      isBestSeller: json['is_best_seller'] as bool? ?? false,
      mainImageUrl: json['main_image_url'] as String?,
      cuttingOptions: json['cutting_options'] as List<dynamic>?,
      packagingOptions: json['packaging_options'] as List<dynamic>?,
      excludedParts: json['excluded_parts'] as List<dynamic>?,
    );

Map<String, dynamic> _$HomeProductModelToJson(HomeProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'selling_price': instance.sellingPrice,
      'offer_price': instance.offerPrice,
      'is_on_offer': instance.isOnOffer,
      'is_best_seller': instance.isBestSeller,
      'main_image_url': instance.mainImageUrl,
      'cutting_options': instance.cuttingOptions,
      'packaging_options': instance.packagingOptions,
      'excluded_parts': instance.excludedParts,
    };

JabinHighlightModel _$JabinHighlightModelFromJson(Map<String, dynamic> json) =>
    JabinHighlightModel(
      user: HighlightUserModel.fromJson(json['user'] as Map<String, dynamic>),
      highlights: (json['highlights'] as List<dynamic>)
          .map((e) => HighlightModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JabinHighlightModelToJson(
  JabinHighlightModel instance,
) => <String, dynamic>{
  'user': instance.user,
  'highlights': instance.highlights,
};

HighlightUserModel _$HighlightUserModelFromJson(Map<String, dynamic> json) =>
    HighlightUserModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$HighlightUserModelToJson(HighlightUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
    };

HighlightModel _$HighlightModelFromJson(Map<String, dynamic> json) =>
    HighlightModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      mediaType: json['media_type'] as String?,
      mediaUrl: json['media_url'] as String?,
    );

Map<String, dynamic> _$HighlightModelToJson(HighlightModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'media_type': instance.mediaType,
      'media_url': instance.mediaUrl,
    };
