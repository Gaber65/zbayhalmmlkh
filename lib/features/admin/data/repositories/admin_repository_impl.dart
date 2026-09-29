import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/error_message_model.dart';
import '../../../user/catalog/domain/entities/category.dart';
import '../../../user/catalog/domain/entities/product.dart';
import '../../../user/orders/domain/entities/order_entity.dart';
import '../../../user/orders/domain/entities/branch_entity.dart';
import '../../../user/offers/domain/entities/offer_entity.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  Failure _handleError(dynamic e) {
    if (e is ServerException) {
      return ServerFailure(e.errorMessageModel);
    }
    return ServerFailure(
      ErrorMessageModel(
        message: e.toString(),
        errors: const [],
        success: false,
        statusCode: 500,
      ),
    );
  }

  @override
  Future<Either<Failure, AdminDashboardStats>> getDashboardStats() async {
    try {
      final result = await remoteDataSource.getDashboardStats();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<OrderListItemEntity>>> getAdminOrders({
    String? state,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getAdminOrders(
        state: state,
        query: query,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> getAdminOrderDetail(int orderId) async {
    try {
      final result = await remoteDataSource.getAdminOrderDetail(orderId);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> updateOrderStatus(
    int orderId,
    String newStatus,
  ) async {
    try {
      final result = await remoteDataSource.updateOrderStatus(orderId, newStatus);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAdminProducts({
    String? query,
    int? categoryId,
    String? filter,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getAdminProducts(
        query: query,
        categoryId: categoryId,
        filter: filter,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createProduct(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateProduct(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Product>> toggleProductAvailability(
    int id,
    bool isAvailable,
  ) async {
    try {
      final result = await remoteDataSource.toggleProductAvailability(id, isAvailable);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getAdminCategories() async {
    try {
      final result = await remoteDataSource.getAdminCategories();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createCategory(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateCategory(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminBannerEntity>>> getAdminBanners() async {
    try {
      final result = await remoteDataSource.getAdminBanners();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminBannerEntity>> createBanner(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createBanner(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminBannerEntity>> updateBanner(int id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateBanner(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBanner(int id) async {
    try {
      await remoteDataSource.deleteBanner(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminOptionEntity>>> getAdminOptions({String? type}) async {
    try {
      final result = await remoteDataSource.getAdminOptions(type: type);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminOptionEntity>> saveOption(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.saveOption(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOption(int id, {String? type}) async {
    try {
      await remoteDataSource.deleteOption(id, type: type);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminSizeEntity>>> getAdminSizes({int? productId}) async {
    try {
      final result = await remoteDataSource.getAdminSizes(productId: productId);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminSizeEntity>> saveSize(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.saveSize(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSize(int id) async {
    try {
      await remoteDataSource.deleteSize(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminCouponEntity>>> getAdminCoupons() async {
    try {
      final result = await remoteDataSource.getAdminCoupons();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminCouponEntity>> createCoupon(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createCoupon(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminCouponEntity>> toggleCoupon(int id, bool isActive) async {
    try {
      final result = await remoteDataSource.toggleCoupon(id, isActive);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCoupon(int id) async {
    try {
      await remoteDataSource.deleteCoupon(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminNotificationEntity>>> getNotifications() async {
    try {
      final result = await remoteDataSource.getNotifications();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationsRead({int? id, bool markAll = false}) async {
    try {
      await remoteDataSource.markNotificationsRead(id: id, markAll: markAll);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> sendBroadcastNotification({
    required String title,
    required String body,
    String? topic,
  }) async {
    try {
      final result = await remoteDataSource.sendBroadcastNotification(
        title: title,
        body: body,
        topic: topic,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // ── 9. Users CRM ──────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<AdminUserEntity>>> getAdminUsers({
    String? status,
    String? userType,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getAdminUsers(
        status: status,
        userType: userType,
        query: query,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getAdminUserDetail(int userId) async {
    try {
      final result = await remoteDataSource.getAdminUserDetail(userId);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> createAdminUser(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createAdminUser(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateAdminUser(int userId, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateAdminUser(userId, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAdminUser(int userId) async {
    try {
      final result = await remoteDataSource.deleteAdminUser(userId);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateAdminUserStatus(
    int userId,
    String status,
  ) async {
    try {
      final result = await remoteDataSource.updateAdminUserStatus(userId, status);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, bool>> adjustUserLoyaltyPoints({
    required int userId,
    required int pointsChange,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.adjustUserLoyaltyPoints(
        userId: userId,
        pointsChange: pointsChange,
        reason: reason,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // ── 10. Highlights / Stories ──────────────────────────────────────────────
  @override
  Future<Either<Failure, List<AdminHighlightEntity>>> getAdminHighlights() async {
    try {
      final result = await remoteDataSource.getAdminHighlights();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminHighlightEntity>> createAdminHighlight(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createAdminHighlight(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAdminHighlight(int id) async {
    try {
      await remoteDataSource.deleteAdminHighlight(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // ── 11. Payments & Loyalty Transactions ───────────────────────────────────
  @override
  Future<Either<Failure, List<AdminPaymentTransactionEntity>>> getPaymentTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getPaymentTransactions(
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminLoyaltyTransactionEntity>>> getLoyaltyTransactions({
    int? customerId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getLoyaltyTransactions(
        customerId: customerId,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminLoyaltySettingsEntity>> getLoyaltySettings() async {
    try {
      final result = await remoteDataSource.getLoyaltySettings();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminLoyaltySettingsEntity>> updateLoyaltySettings({
    required double earningRate,
    required double redemptionRate,
    required int minRedemption,
  }) async {
    try {
      final result = await remoteDataSource.updateLoyaltySettings(
        earningRate: earningRate,
        redemptionRate: redemptionRate,
        minRedemption: minRedemption,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // ── 12. Branches Management ───────────────────────────────────────────────
  @override
  Future<Either<Failure, List<BranchEntity>>> getAdminBranches({bool includeInactive = true}) async {
    try {
      final result = await remoteDataSource.getAdminBranches(includeInactive: includeInactive);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BranchEntity>> createBranch(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createBranch(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BranchEntity>> updateBranch(int id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateBranch(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBranch(int id) async {
    try {
      await remoteDataSource.deleteBranch(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // ── 13. Offers Management ─────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<OfferEntity>>> getAdminOffers({bool includeInactive = true}) async {
    try {
      final result = await remoteDataSource.getAdminOffers(includeInactive: includeInactive);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, OfferEntity>> createOffer(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createOffer(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, OfferEntity>> updateOffer(int id, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateOffer(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOffer(int id) async {
    try {
      await remoteDataSource.deleteOffer(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, OfferEntity>> toggleOfferActive(int id) async {
    try {
      final result = await remoteDataSource.toggleOfferActive(id);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // ── 14. Contact Settings ──────────────────────────────────────────────────
  @override
  Future<Either<Failure, AdminContactSettingsEntity>> getContactSettings() async {
    try {
      final result = await remoteDataSource.getContactSettings();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AdminContactSettingsEntity>> updateContactSettings({
    required String whatsappNumber,
    required String whatsappDefaultMessage,
    required bool whatsappEnabled,
    required String supportPhone,
  }) async {
    try {
      final result = await remoteDataSource.updateContactSettings(
        whatsappNumber: whatsappNumber,
        whatsappDefaultMessage: whatsappDefaultMessage,
        whatsappEnabled: whatsappEnabled,
        supportPhone: supportPhone,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
}

