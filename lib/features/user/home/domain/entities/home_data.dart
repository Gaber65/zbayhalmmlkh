import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/offers/domain/entities/offer_entity.dart';

class HomeData extends Equatable {
  final String? deliveryLocation;
  final UserHighlight? userHighlight;
  final List<BannerEntity> banners;
  final List<OfferEntity> offers;
  final List<Category> categories;
  final List<Product> featuredProducts;
  final List<Product> bestSellers;
  final List<Product> recommendedProducts;
  final List<JabinHighlightEntity> jabinHighlight;

  const HomeData({
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

class UserHighlight extends Equatable {
  final int id;
  final String name;
  final String email;
  final String avatarUrl;
  final double balance;
  final ActiveCart? activeCart;

  const UserHighlight({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.balance,
    this.activeCart,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, balance, activeCart];
}

class ActiveCart extends Equatable {
  final int id;
  final String status;
  final int lineCount;

  const ActiveCart({
    required this.id,
    required this.status,
    required this.lineCount,
  });

  @override
  List<Object?> get props => [id, status, lineCount];
}

class BannerEntity extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final String? bannerType;
  final int? offerId;
  final String? deepLink;

  const BannerEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.bannerType,
    this.offerId,
    this.deepLink,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, bannerType, offerId, deepLink];
}

class JabinHighlightEntity extends Equatable {
  final HighlightUser user;
  final List<HighlightEntity> highlights;

  const JabinHighlightEntity({
    required this.user,
    required this.highlights,
  });

  @override
  List<Object?> get props => [user, highlights];
}

class HighlightUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String avatarUrl;

  const HighlightUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}

class HighlightEntity extends Equatable {
  final int id;
  final String name;
  final String mediaType;
  final String mediaUrl;

  const HighlightEntity({
    required this.id,
    required this.name,
    required this.mediaType,
    required this.mediaUrl,
  });

  @override
  List<Object?> get props => [id, name, mediaType, mediaUrl];
}

