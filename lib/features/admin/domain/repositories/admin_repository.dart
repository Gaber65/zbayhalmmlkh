import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../user/catalog/domain/entities/category.dart';
import '../../../user/catalog/domain/entities/product.dart';
import '../../../user/orders/domain/entities/order_entity.dart';
import '../../../user/orders/domain/entities/branch_entity.dart';
import '../../../user/offers/domain/entities/offer_entity.dart';
import '../entities/admin_entities.dart';

abstract class AdminRepository {
  // ── 1. Dashboard & Analytics ──────────────────────────────────────────────
  Future<Either<Failure, AdminDashboardStats>> getDashboardStats();

  // ── 2. Orders Management ──────────────────────────────────────────────────
  Future<Either<Failure, List<OrderListItemEntity>>> getAdminOrders({
    String? state,
    String? query,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, OrderDetailEntity>> getAdminOrderDetail(int orderId);

  Future<Either<Failure, OrderDetailEntity>> updateOrderStatus(
    int orderId,
    String newStatus,
  );

  // ── 3. Products Management (CRUD) ─────────────────────────────────────────
  Future<Either<Failure, List<Product>>> getAdminProducts({
    String? query,
    int? categoryId,
    String? filter,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, Product>> createProduct(Map<String, dynamic> data);

  Future<Either<Failure, Product>> updateProduct(int id, Map<String, dynamic> data);

  Future<Either<Failure, void>> deleteProduct(int id);

  Future<Either<Failure, Product>> toggleProductAvailability(
    int id,
    bool isAvailable,
  );

  // ── 4. Categories Management (CRUD) ───────────────────────────────────────
  Future<Either<Failure, List<Category>>> getAdminCategories();

  Future<Either<Failure, Category>> createCategory(Map<String, dynamic> data);

  Future<Either<Failure, Category>> updateCategory(int id, Map<String, dynamic> data);

  Future<Either<Failure, void>> deleteCategory(int id);

  // ── 5. Banners Management (CRUD) ──────────────────────────────────────────
  Future<Either<Failure, List<AdminBannerEntity>>> getAdminBanners();

  Future<Either<Failure, AdminBannerEntity>> createBanner(Map<String, dynamic> data);
  Future<Either<Failure, AdminBannerEntity>> updateBanner(int id, Map<String, dynamic> data);

  Future<Either<Failure, void>> deleteBanner(int id);

  // ── 6. Options Management (CRUD) ──────────────────────────────────────────
  Future<Either<Failure, List<AdminOptionEntity>>> getAdminOptions({String? type});

  Future<Either<Failure, AdminOptionEntity>> saveOption(Map<String, dynamic> data);

  Future<Either<Failure, void>> deleteOption(int id, {String? type});

  // ── 6.1 Product Carcass Sizes (CRUD) ──────────────────────────────────────
  Future<Either<Failure, List<AdminSizeEntity>>> getAdminSizes({int? productId});
  Future<Either<Failure, AdminSizeEntity>> saveSize(Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteSize(int id);

  // ── 7. Coupons Management (CRUD) ──────────────────────────────────────────
  Future<Either<Failure, List<AdminCouponEntity>>> getAdminCoupons();

  Future<Either<Failure, AdminCouponEntity>> createCoupon(Map<String, dynamic> data);

  Future<Either<Failure, AdminCouponEntity>> toggleCoupon(int id, bool isActive);

  Future<Either<Failure, void>> deleteCoupon(int id);

  // ── 8. Notifications ──────────────────────────────────────────────────────
  Future<Either<Failure, List<AdminNotificationEntity>>> getNotifications();

  Future<Either<Failure, void>> markNotificationsRead({int? id, bool markAll = false});

  Future<Either<Failure, bool>> sendBroadcastNotification({
    required String title,
    required String body,
    String? topic,
  });

  // ── 9. Users CRM ──────────────────────────────────────────────────────────
  Future<Either<Failure, List<AdminUserEntity>>> getAdminUsers({
    String? status,
    String? userType,
    String? query,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, AdminUserEntity>> getAdminUserDetail(int userId);
  Future<Either<Failure, AdminUserEntity>> createAdminUser(Map<String, dynamic> data);
  Future<Either<Failure, AdminUserEntity>> updateAdminUser(int userId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteAdminUser(int userId);

  Future<Either<Failure, AdminUserEntity>> updateAdminUserStatus(
    int userId,
    String status,
  );

  Future<Either<Failure, bool>> adjustUserLoyaltyPoints({
    required int userId,
    required int pointsChange,
    required String reason,
  });

  // ── 10. Highlights / Stories ──────────────────────────────────────────────
  Future<Either<Failure, List<AdminHighlightEntity>>> getAdminHighlights();

  Future<Either<Failure, AdminHighlightEntity>> createAdminHighlight(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, void>> deleteAdminHighlight(int id);

  // ── 11. Payments & Loyalty Transactions ───────────────────────────────────
  Future<Either<Failure, List<AdminPaymentTransactionEntity>>> getPaymentTransactions({
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, List<AdminLoyaltyTransactionEntity>>> getLoyaltyTransactions({
    int? customerId,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, AdminLoyaltySettingsEntity>> getLoyaltySettings();

  Future<Either<Failure, AdminLoyaltySettingsEntity>> updateLoyaltySettings({
    required double earningRate,
    required double redemptionRate,
    required int minRedemption,
  });

  // ── 12. Branches Management (CRUD) ────────────────────────────────────────
  Future<Either<Failure, List<BranchEntity>>> getAdminBranches({bool includeInactive = true});
  Future<Either<Failure, BranchEntity>> createBranch(Map<String, dynamic> data);
  Future<Either<Failure, BranchEntity>> updateBranch(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteBranch(int id);

  // ── 13. Offers / Promotions Management (CRUD) ──────────────────────────────
  Future<Either<Failure, List<OfferEntity>>> getAdminOffers({bool includeInactive = true});
  Future<Either<Failure, OfferEntity>> createOffer(Map<String, dynamic> data);
  Future<Either<Failure, OfferEntity>> updateOffer(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteOffer(int id);
  Future<Either<Failure, OfferEntity>> toggleOfferActive(int id);

  // ── 14. Contact / WhatsApp Settings ───────────────────────────────────────
  Future<Either<Failure, AdminContactSettingsEntity>> getContactSettings();
  Future<Either<Failure, AdminContactSettingsEntity>> updateContactSettings({
    required String whatsappNumber,
    required String whatsappDefaultMessage,
    required bool whatsappEnabled,
    required String supportPhone,
  });
}


