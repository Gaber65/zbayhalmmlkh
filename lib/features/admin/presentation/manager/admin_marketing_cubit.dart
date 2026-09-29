import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../user/offers/domain/entities/offer_entity.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminMarketingState extends Equatable {
  const AdminMarketingState();
  @override
  List<Object?> get props => [];
}

class AdminMarketingInitial extends AdminMarketingState {}

class AdminMarketingLoading extends AdminMarketingState {}

class AdminMarketingLoaded extends AdminMarketingState {
  final List<AdminBannerEntity> banners;
  final List<AdminCouponEntity> coupons;
  final List<AdminHighlightEntity> highlights;
  final List<OfferEntity> offers;
  final bool isSubmitting;

  const AdminMarketingLoaded({
    required this.banners,
    required this.coupons,
    this.highlights = const [],
    this.offers = const [],
    this.isSubmitting = false,
  });

  AdminMarketingLoaded copyWith({
    List<AdminBannerEntity>? banners,
    List<AdminCouponEntity>? coupons,
    List<AdminHighlightEntity>? highlights,
    List<OfferEntity>? offers,
    bool? isSubmitting,
  }) {
    return AdminMarketingLoaded(
      banners: banners ?? this.banners,
      coupons: coupons ?? this.coupons,
      highlights: highlights ?? this.highlights,
      offers: offers ?? this.offers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [banners, coupons, highlights, offers, isSubmitting];
}

class AdminMarketingError extends AdminMarketingState {
  final String message;
  const AdminMarketingError({required this.message});
  @override
  List<Object?> get props => [message];
}

@injectable
class AdminMarketingCubit extends Cubit<AdminMarketingState> {
  final AdminRepository repository;

  AdminMarketingCubit({required this.repository}) : super(AdminMarketingInitial());

  Future<void> loadMarketingData({bool silent = false}) async {
    if (!silent) emit(AdminMarketingLoading());

    final bannersRes = await repository.getAdminBanners();
    final couponsRes = await repository.getAdminCoupons();
    final highlightsRes = await repository.getAdminHighlights();
    final offersRes = await repository.getAdminOffers();

    final banners = bannersRes.getOrElse(() => []);
    final coupons = couponsRes.getOrElse(() => []);
    final highlights = highlightsRes.getOrElse(() => []);
    final offers = offersRes.getOrElse(() => []);

    emit(AdminMarketingLoaded(
      banners: banners,
      coupons: coupons,
      highlights: highlights,
      offers: offers,
    ));
  }

  Future<bool> createBanner(Map<String, dynamic> data) async {
    if (state is AdminMarketingLoaded) {
      emit((state as AdminMarketingLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.createBanner(data);
    return result.fold(
      (failure) {
        if (state is AdminMarketingLoaded) {
          emit((state as AdminMarketingLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> updateBanner(int id, Map<String, dynamic> data) async {
    if (state is AdminMarketingLoaded) {
      emit((state as AdminMarketingLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.updateBanner(id, data);
    return result.fold(
      (failure) {
        if (state is AdminMarketingLoaded) {
          emit((state as AdminMarketingLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteBanner(int id) async {
    final result = await repository.deleteBanner(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> createHighlight(Map<String, dynamic> data) async {
    if (state is AdminMarketingLoaded) {
      emit((state as AdminMarketingLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.createAdminHighlight(data);
    return result.fold(
      (failure) {
        if (state is AdminMarketingLoaded) {
          emit((state as AdminMarketingLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteHighlight(int id) async {
    final result = await repository.deleteAdminHighlight(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> createCoupon(Map<String, dynamic> data) async {
    if (state is AdminMarketingLoaded) {
      emit((state as AdminMarketingLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.createCoupon(data);
    return result.fold(
      (failure) {
        if (state is AdminMarketingLoaded) {
          emit((state as AdminMarketingLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> toggleCoupon(int id, bool isActive) async {
    final result = await repository.toggleCoupon(id, isActive);
    return result.fold(
      (failure) => false,
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteCoupon(int id) async {
    final result = await repository.deleteCoupon(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  // ── Offers Management ─────────────────────────────────────────────────────
  Future<bool> createOffer(Map<String, dynamic> data) async {
    if (state is AdminMarketingLoaded) {
      emit((state as AdminMarketingLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.createOffer(data);
    return result.fold(
      (failure) {
        if (state is AdminMarketingLoaded) {
          emit((state as AdminMarketingLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> updateOffer(int id, Map<String, dynamic> data) async {
    if (state is AdminMarketingLoaded) {
      emit((state as AdminMarketingLoaded).copyWith(isSubmitting: true));
    }

    final result = await repository.updateOffer(id, data);
    return result.fold(
      (failure) {
        if (state is AdminMarketingLoaded) {
          emit((state as AdminMarketingLoaded).copyWith(isSubmitting: false));
        }
        return false;
      },
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> deleteOffer(int id) async {
    final result = await repository.deleteOffer(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> toggleOffer(int id) async {
    final result = await repository.toggleOfferActive(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadMarketingData(silent: true);
        return true;
      },
    );
  }

  Future<bool> sendBroadcastNotification({
    required String title,
    required String body,
    String? topic,
  }) async {
    final result = await repository.sendBroadcastNotification(
      title: title,
      body: body,
      topic: topic,
    );
    return result.getOrElse(() => false);
  }

  Future<bool> sendBroadcast({
    required String title,
    required String body,
    String? topic,
  }) async {
    return sendBroadcastNotification(title: title, body: body, topic: topic);
  }
}
