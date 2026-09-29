import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import 'package:dhabayih_lmamlaka/core/theme/app_theme.dart';
import 'package:dhabayih_lmamlaka/features/admin/domain/entities/admin_entities.dart';
import 'package:dhabayih_lmamlaka/features/admin/domain/repositories/admin_repository.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/category.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/entities/order_entity.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/entities/branch_entity.dart';
import 'package:dhabayih_lmamlaka/features/user/offers/domain/entities/offer_entity.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';

Failure mockFailure([String msg = 'Operation failed']) {
  return ServerFailure(ErrorMessageModel(
    message: msg,
    errors: const [],
    success: false,
    statusCode: 400,
  ));
}

/// Wraps widgets for testing with full localizations, ScreenUtil, and theme.
Widget createTestAppWidget({
  required Widget child,
  Locale locale = const Locale('ar'),
  ThemeData? theme,
  NavigatorObserver? navigatorObserver,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      navigatorObservers: navigatorObserver != null ? [navigatorObserver] : const [],
      home: Scaffold(body: child),
    ),
  );
}

/// Comprehensive fake implementation of [AdminRepository] for unit & widget tests.
class FakeAdminRepository implements AdminRepository {
  bool shouldFail = false;
  String failureMessage = 'Failed to perform operation';

  // Categories
  List<Category> categories = [
    const Category(id: 1, name: 'ذبائح نعيمي', imageUrl: 'http://example.com/cat1.png'),
    const Category(id: 2, name: 'عجول وبلدي', imageUrl: 'http://example.com/cat2.png'),
  ];
  Map<String, dynamic>? lastCreatedCategoryPayload;
  int? lastUpdatedCategoryId;
  Map<String, dynamic>? lastUpdatedCategoryPayload;
  int? lastDeletedCategoryId;

  // Products
  List<Product> products = [
    const Product(
      id: 101,
      title: 'خروف نعيمي بلدي',
      subtitle: 'طازج يومياً',
      price: 1350.0,
      imageUrl: 'http://example.com/p1.png',
      isAvailable: true,
      categoryId: 1,
    ),
    const Product(
      id: 102,
      title: 'تيس بلدي عارضي',
      subtitle: 'مختار بعناية',
      price: 1100.0,
      imageUrl: 'http://example.com/p2.png',
      isAvailable: true,
      categoryId: 2,
    ),
  ];
  Map<String, dynamic>? lastCreatedProductPayload;
  int? lastUpdatedProductId;
  Map<String, dynamic>? lastUpdatedProductPayload;
  int? lastDeletedProductId;
  int? lastToggledProductId;
  bool? lastToggledProductAvailability;

  // Customization Options
  List<AdminOptionEntity> options = [
    const AdminOptionEntity(id: 201, name: 'تقطيع ثلاجة', extraPrice: 0.0, type: 'cutting', isActive: true),
    const AdminOptionEntity(id: 202, name: 'تغليف سحب هواء', extraPrice: 15.0, type: 'packaging', isActive: true),
  ];
  Map<String, dynamic>? lastSavedOptionPayload;
  int? lastDeletedOptionId;

  // Marketing: Banners, Coupons, Highlights
  List<AdminBannerEntity> banners = [
    const AdminBannerEntity(id: 301, title: 'خصومات عيد الفطر', imageUrl: 'http://example.com/b1.png', displayOrder: 1, isActive: true),
  ];
  Map<String, dynamic>? lastCreatedBannerPayload;
  int? lastUpdatedBannerId;
  Map<String, dynamic>? lastUpdatedBannerPayload;
  int? lastDeletedBannerId;

  List<AdminCouponEntity> coupons = [
    const AdminCouponEntity(id: 401, code: 'EID20', discountType: 'percentage', discountValue: 20.0, minOrderValue: 500.0, expiryDate: '2026-12-31', isActive: true),
  ];
  Map<String, dynamic>? lastCreatedCouponPayload;
  int? lastToggledCouponId;
  bool? lastToggledCouponActive;
  int? lastDeletedCouponId;

  List<AdminHighlightEntity> highlights = [
    const AdminHighlightEntity(id: 501, mediaUrl: 'http://example.com/story.mp4', mediaType: 'video', title: 'وصول ذبائح اليوم'),
  ];
  Map<String, dynamic>? lastCreatedHighlightPayload;
  int? lastDeletedHighlightId;

  String? lastBroadcastTitle;
  String? lastBroadcastBody;
  String? lastBroadcastTopic;

  // Orders
  List<OrderListItemEntity> orders = [
    const OrderListItemEntity(
      id: 601,
      name: 'SO001',
      date: '2026-09-26 12:00:00',
      total: 1350.0,
      subtotal: 1350.0,
      discountAmount: 0.0,
      taxAmount: 0.0,
      paymentStatus: 'pending',
      itemCount: 1,
      state: 'pending',
      customerName: 'محمد أحمد',
      customerPhone: '0501112233',
    ),
    const OrderListItemEntity(
      id: 602,
      name: 'SO002',
      date: '2026-09-26 13:00:00',
      total: 2200.0,
      subtotal: 2200.0,
      discountAmount: 0.0,
      taxAmount: 0.0,
      paymentStatus: 'paid',
      itemCount: 2,
      state: 'confirmed',
      customerName: 'فهد العتيبي',
      customerPhone: '0504445566',
    ),
  ];
  int? lastUpdatedOrderStatusId;
  String? lastUpdatedOrderNewStatus;

  // Customers CRM
  List<AdminUserEntity> users = [
    const AdminUserEntity(
      id: 701,
      name: 'سالم الشمري',
      email: 'salem@example.com',
      phone: '0509998877',
      status: 'active',
      userType: 'individual',
      loyaltyPoints: 350,
      totalOrdersCount: 4,
      totalSpending: 4500.0,
    ),
  ];
  Map<String, dynamic>? lastCreatedUserPayload;
  int? lastUpdatedUserId;
  Map<String, dynamic>? lastUpdatedUserPayload;
  int? lastDeletedUserId;
  int? lastUpdatedUserStatusId;
  String? lastUpdatedUserNewStatus;
  int? lastAdjustedLoyaltyUserId;
  int? lastAdjustedLoyaltyPoints;
  String? lastAdjustedLoyaltyReason;

  // Payments & Loyalty Transactions
  List<AdminPaymentTransactionEntity> paymentTransactions = [
    const AdminPaymentTransactionEntity(
      id: 801,
      orderName: 'SO001',
      customerName: 'محمد أحمد',
      paymentMethod: 'mada',
      amount: 1350.0,
      status: 'done',
      transactionReference: 'TXN-998877',
    ),
  ];
  List<AdminLoyaltyTransactionEntity> loyaltyTransactions = [
    const AdminLoyaltyTransactionEntity(
      id: 901,
      date: '2026-09-26',
      customerName: 'سالم الشمري',
      transactionType: 'earn',
      points: 135,
      balanceAfter: 350,
      description: 'نقاط من طلب SO001',
      createdBy: 'System',
    ),
  ];

  // Loyalty Settings
  AdminLoyaltySettingsEntity loyaltySettings = const AdminLoyaltySettingsEntity(
    earningRate: 1.0,
    redemptionRate: 100.0,
    minRedemption: 500,
  );
  AdminLoyaltySettingsEntity? lastUpdatedLoyaltySettings;

  // Dashboard Stats
  AdminDashboardStats dashboardStats = const AdminDashboardStats(
    totalOrders: 150,
    pendingOrders: 12,
    preparingOrders: 8,
    deliveringOrders: 5,
    completedOrders: 120,
    cancelledOrders: 5,
    todaySales: 15400.0,
    monthlySales: 184500.0,
    totalProducts: 48,
    lowStockCount: 3,
    totalCustomers: 95,
  );

  // Branches
  List<BranchEntity> branches = [
    const BranchEntity(
      id: 1,
      name: 'فرع الرياض الرئيسي',
      code: 'RUH-01',
      address: 'طريق الملك فهد، حي الصحافة',
      city: 'الرياض',
      phone: '0501112233',
      openingHours: '08:00 AM - 11:00 PM',
      isActive: true,
    ),
    const BranchEntity(
      id: 2,
      name: 'فرع جدة',
      code: 'JED-01',
      address: 'طريق الأندلس، حي الحمراء',
      city: 'جدة',
      phone: '0502223344',
      openingHours: '09:00 AM - 11:30 PM',
      isActive: true,
    ),
  ];
  Map<String, dynamic>? lastCreatedBranchPayload;
  int? lastUpdatedBranchId;
  Map<String, dynamic>? lastUpdatedBranchPayload;
  int? lastDeletedBranchId;

  // Offers
  List<OfferEntity> offers = [
    const OfferEntity(
      id: 1,
      name: 'عرض العيد المميز',
      subtitle: 'خصم خاص على الذبائح النعيمي',
      description: 'استمتع بأفضل الأسعار على النعيمي الطازج',
      discountType: 'percentage',
      discountValue: 15.0,
      badgeText: 'خصم 15%',
      isActive: true,
      productIds: [101, 102],
    ),
  ];
  Map<String, dynamic>? lastCreatedOfferPayload;
  Map<String, dynamic>? lastUpdatedOfferPayload;
  int? lastDeletedOfferId;
  int? lastToggledOfferId;

  // Contact Settings
  AdminContactSettingsEntity contactSettings = const AdminContactSettingsEntity(
    whatsappNumber: '+966500000000',
    whatsappDefaultMessage: 'مرحباً، أود الاستفسار عن ذبائح المملكة',
    whatsappEnabled: true,
    supportPhone: '920000000',
    deliveryFee: 31.95,
  );
  AdminContactSettingsEntity? lastUpdatedContactSettings;

  // ── Categories Methods ───────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<Category>>> getAdminCategories() async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(categories);
  }

  @override
  Future<Either<Failure, Category>> createCategory(Map<String, dynamic> data) async {
    lastCreatedCategoryPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final cat = Category(
      id: 10 + categories.length,
      name: data['name'] ?? 'قسم جديد',
      imageUrl: data['image'] != null ? 'http://example.com/new.png' : '',
    );
    categories.add(cat);
    return Right(cat);
  }

  @override
  Future<Either<Failure, Category>> updateCategory(int id, Map<String, dynamic> data) async {
    lastUpdatedCategoryId = id;
    lastUpdatedCategoryPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = categories.indexWhere((c) => c.id == id);
    final updated = Category(
      id: id,
      name: data['name'] ?? (idx >= 0 ? categories[idx].name : 'محدث'),
      imageUrl: idx >= 0 ? categories[idx].imageUrl : '',
    );
    if (idx >= 0) categories[idx] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int id) async {
    lastDeletedCategoryId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    categories.removeWhere((c) => c.id == id);
    return const Right(null);
  }

  // ── Products Methods ─────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<Product>>> getAdminProducts({
    String? query,
    int? categoryId,
    String? filter,
    int limit = 20,
    int offset = 0,
  }) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    var list = products;
    if (query != null && query.isNotEmpty) {
      list = list.where((p) => p.title.contains(query)).toList();
    }
    if (categoryId != null) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    return Right(list);
  }

  @override
  Future<Either<Failure, Product>> createProduct(Map<String, dynamic> data) async {
    lastCreatedProductPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final p = Product(
      id: 200 + products.length,
      title: data['name'] ?? 'منتج جديد',
      subtitle: '',
      price: (data['selling_price'] as num?)?.toDouble() ?? 100.0,
      imageUrl: 'http://example.com/new_prod.png',
      categoryId: data['category_id'] as int?,
      isAvailable: true,
      description: data['description'] ?? '',
    );
    products.add(p);
    return Right(p);
  }

  @override
  Future<Either<Failure, Product>> updateProduct(int id, Map<String, dynamic> data) async {
    lastUpdatedProductId = id;
    lastUpdatedProductPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = products.indexWhere((p) => p.id == id);
    final updated = Product(
      id: id,
      title: data['name'] ?? (idx >= 0 ? products[idx].title : 'محدث'),
      subtitle: idx >= 0 ? products[idx].subtitle : '',
      price: (data['selling_price'] as num?)?.toDouble() ?? (idx >= 0 ? products[idx].price : 100.0),
      imageUrl: idx >= 0 ? products[idx].imageUrl : '',
      categoryId: (data['category_id'] as int?) ?? (idx >= 0 ? products[idx].categoryId : null),
      isAvailable: idx >= 0 ? products[idx].isAvailable : true,
    );
    if (idx >= 0) products[idx] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    lastDeletedProductId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    products.removeWhere((p) => p.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, Product>> toggleProductAvailability(int id, bool isAvailable) async {
    lastToggledProductId = id;
    lastToggledProductAvailability = isAvailable;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = products.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      final p = products[idx];
      final updated = Product(
        id: p.id,
        title: p.title,
        subtitle: p.subtitle,
        price: p.price,
        imageUrl: p.imageUrl,
        categoryId: p.categoryId,
        isAvailable: isAvailable,
      );
      products[idx] = updated;
      return Right(updated);
    }
    return Left(mockFailure('Product not found'));
  }

  // ── Options Methods ──────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<AdminOptionEntity>>> getAdminOptions({String? type}) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    if (type != null) {
      return Right(options.where((o) => o.type == type).toList());
    }
    return Right(options);
  }

  @override
  Future<Either<Failure, AdminOptionEntity>> saveOption(Map<String, dynamic> data) async {
    lastSavedOptionPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final id = data['id'] as int? ?? (300 + options.length);
    final opt = AdminOptionEntity(
      id: id,
      name: data['name'] ?? 'خيار جديد',
      type: data['type'] ?? 'cutting',
      extraPrice: (data['extra_price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String?,
      isActive: data['is_active'] as bool? ?? true,
    );
    final idx = options.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      options[idx] = opt;
    } else {
      options.add(opt);
    }
    return Right(opt);
  }

  @override
  Future<Either<Failure, void>> deleteOption(int id, {String? type}) async {
    lastDeletedOptionId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    options.removeWhere((o) => o.id == id);
    return const Right(null);
  }

  // ── Sizes Methods ────────────────────────────────────────────────────────
  List<AdminSizeEntity> sizes = [
    const AdminSizeEntity(
      id: 1,
      productId: 1,
      productName: 'ذبيحة نعيمي بلدي',
      name: 'هرفي وسط',
      subTitle: 'يجزئ عقيقة',
      price: 1350.0,
      calories: 243,
      isDefault: true,
      isActive: true,
    ),
  ];
  int? lastDeletedSizeId;
  Map<String, dynamic>? lastSavedSizePayload;

  @override
  Future<Either<Failure, List<AdminSizeEntity>>> getAdminSizes({int? productId}) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    if (productId != null) {
      return Right(sizes.where((s) => s.productId == productId).toList());
    }
    return Right(sizes);
  }

  @override
  Future<Either<Failure, AdminSizeEntity>> saveSize(Map<String, dynamic> data) async {
    lastSavedSizePayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final id = data['id'] as int? ?? (100 + sizes.length);
    final size = AdminSizeEntity(
      id: id,
      productId: data['product_id'] ?? 1,
      name: data['name'] ?? 'حجم جديد',
      subTitle: data['sub_title'],
      price: (data['price'] as num?)?.toDouble() ?? 1200.0,
      calories: (data['calories'] as num?)?.toInt() ?? 243,
      isDefault: data['is_default'] ?? false,
      isActive: data['is_active'] ?? data['active'] ?? true,
    );
    final idx = sizes.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      sizes[idx] = size;
    } else {
      sizes.add(size);
    }
    return Right(size);
  }

  @override
  Future<Either<Failure, void>> deleteSize(int id) async {
    lastDeletedSizeId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    sizes.removeWhere((s) => s.id == id);
    return const Right(null);
  }

  // ── Marketing Methods ────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<AdminBannerEntity>>> getAdminBanners() async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(banners);
  }

  @override
  Future<Either<Failure, AdminBannerEntity>> createBanner(Map<String, dynamic> data) async {
    lastCreatedBannerPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final b = AdminBannerEntity(
      id: 400 + banners.length,
      title: data['title'] ?? 'بنر جديد',
      imageUrl: 'http://example.com/new_banner.png',
      displayOrder: data['sequence'] ?? 1,
      isActive: data['is_active'] ?? true,
    );
    banners.add(b);
    return Right(b);
  }

  @override
  Future<Either<Failure, AdminBannerEntity>> updateBanner(int id, Map<String, dynamic> data) async {
    lastUpdatedBannerId = id;
    lastUpdatedBannerPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = banners.indexWhere((b) => b.id == id);
    final updated = AdminBannerEntity(
      id: id,
      title: data['title'] ?? (idx >= 0 ? banners[idx].title : 'محدث'),
      imageUrl: idx >= 0 ? banners[idx].imageUrl : 'http://example.com/banner.png',
      displayOrder: data['sequence'] ?? (idx >= 0 ? banners[idx].displayOrder : 1),
      isActive: data['is_active'] ?? (idx >= 0 ? banners[idx].isActive : true),
    );
    if (idx >= 0) banners[idx] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, void>> deleteBanner(int id) async {
    lastDeletedBannerId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    banners.removeWhere((b) => b.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<AdminCouponEntity>>> getAdminCoupons() async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(coupons);
  }

  @override
  Future<Either<Failure, AdminCouponEntity>> createCoupon(Map<String, dynamic> data) async {
    lastCreatedCouponPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final c = AdminCouponEntity(
      id: 500 + coupons.length,
      code: data['code'] ?? 'CODE',
      discountType: data['discount_type'] ?? 'percentage',
      discountValue: (data['discount_value'] as num?)?.toDouble() ?? 10.0,
      minOrderValue: (data['min_order_value'] as num?)?.toDouble() ?? 0.0,
      expiryDate: data['expiry_date'] ?? '2026-12-31',
      isActive: true,
    );
    coupons.add(c);
    return Right(c);
  }

  @override
  Future<Either<Failure, AdminCouponEntity>> toggleCoupon(int id, bool isActive) async {
    lastToggledCouponId = id;
    lastToggledCouponActive = isActive;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = coupons.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      final updated = coupons[idx].copyWith(isActive: isActive);
      coupons[idx] = updated;
      return Right(updated);
    }
    return Left(mockFailure('Coupon not found'));
  }

  @override
  Future<Either<Failure, void>> deleteCoupon(int id) async {
    lastDeletedCouponId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    coupons.removeWhere((c) => c.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<AdminHighlightEntity>>> getAdminHighlights() async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(highlights);
  }

  @override
  Future<Either<Failure, AdminHighlightEntity>> createAdminHighlight(Map<String, dynamic> data) async {
    lastCreatedHighlightPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final h = AdminHighlightEntity(
      id: 600 + highlights.length,
      mediaUrl: 'http://example.com/story.mp4',
      mediaType: data['media_type'] ?? 'video',
      title: data['title'] ?? 'قصة جديدة',
    );
    highlights.add(h);
    return Right(h);
  }

  @override
  Future<Either<Failure, void>> deleteAdminHighlight(int id) async {
    lastDeletedHighlightId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    highlights.removeWhere((h) => h.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> sendBroadcastNotification({
    required String title,
    required String body,
    String? topic,
  }) async {
    lastBroadcastTitle = title;
    lastBroadcastBody = body;
    lastBroadcastTopic = topic;
    if (shouldFail) return Left(mockFailure(failureMessage));
    return const Right(true);
  }

  // ── Orders Methods ───────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<OrderListItemEntity>>> getAdminOrders({
    String? state,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    var list = orders;
    if (state != null && state.isNotEmpty && state != 'all') {
      list = list.where((o) => o.state == state).toList();
    }
    if (query != null && query.isNotEmpty) {
      list = list.where((o) => o.name.contains(query) || (o.customerName?.contains(query) ?? false)).toList();
    }
    return Right(list);
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> getAdminOrderDetail(int orderId) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = orders.indexWhere((o) => o.id == orderId);
    final order = idx >= 0 ? orders[idx] : orders.first;
    return Right(OrderDetailEntity(
      id: order.id,
      name: order.name,
      date: order.date,
      state: order.state,
      paymentStatus: order.paymentStatus,
      subtotal: order.subtotal,
      discountAmount: order.discountAmount,
      pointsRedeemed: 0,
      loyaltyDiscountAmount: 0.0,
      taxAmount: order.taxAmount,
      total: order.total,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      lines: const [],
      timeline: const [],
    ));
  }

  @override
  Future<Either<Failure, OrderDetailEntity>> updateOrderStatus(int orderId, String newStatus) async {
    lastUpdatedOrderStatusId = orderId;
    lastUpdatedOrderNewStatus = newStatus;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final o = orders[idx];
      orders[idx] = OrderListItemEntity(
        id: o.id,
        name: o.name,
        date: o.date,
        total: o.total,
        subtotal: o.subtotal,
        discountAmount: o.discountAmount,
        taxAmount: o.taxAmount,
        paymentStatus: o.paymentStatus,
        itemCount: o.itemCount,
        state: newStatus,
        customerName: o.customerName,
        customerPhone: o.customerPhone,
      );
    }
    return getAdminOrderDetail(orderId);
  }

  // ── Users / CRM Methods ──────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<AdminUserEntity>>> getAdminUsers({
    String? status,
    String? userType,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    var list = users;
    if (status != null && status.isNotEmpty) {
      list = list.where((u) => u.status == status).toList();
    }
    if (userType != null && userType.isNotEmpty) {
      list = list.where((u) => u.userType == userType).toList();
    }
    if (query != null && query.isNotEmpty) {
      list = list.where((u) => u.name.contains(query) || (u.phone?.contains(query) ?? false)).toList();
    }
    return Right(list);
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getAdminUserDetail(int userId) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx >= 0) return Right(users[idx]);
    return Right(users.first);
  }

  @override
  Future<Either<Failure, AdminUserEntity>> createAdminUser(Map<String, dynamic> data) async {
    lastCreatedUserPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final u = AdminUserEntity(
      id: 800 + users.length,
      name: data['name'] ?? 'عميل جديد',
      phone: data['phone'] ?? '0500000000',
      email: data['email'] ?? 'user@test.com',
      userType: data['user_type'] ?? 'individual',
      status: 'active',
      loyaltyPoints: int.tryParse('${data['loyalty_points']}') ?? 0,
    );
    users.add(u);
    return Right(u);
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateAdminUser(int userId, Map<String, dynamic> data) async {
    lastUpdatedUserId = userId;
    lastUpdatedUserPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = users.indexWhere((u) => u.id == userId);
    final existing = idx >= 0 ? users[idx] : users.first;
    final updated = existing.copyWith(
      name: data['name'] ?? existing.name,
      phone: data['phone'] ?? existing.phone,
      email: data['email'] ?? existing.email,
      userType: data['user_type'] ?? existing.userType,
    );
    if (idx >= 0) users[idx] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, void>> deleteAdminUser(int userId) async {
    lastDeletedUserId = userId;
    if (shouldFail) return Left(mockFailure(failureMessage));
    users.removeWhere((u) => u.id == userId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateAdminUserStatus(int userId, String status) async {
    lastUpdatedUserStatusId = userId;
    lastUpdatedUserNewStatus = status;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      final updated = users[idx].copyWith(status: status);
      users[idx] = updated;
      return Right(updated);
    }
    return Left(mockFailure('User not found'));
  }

  @override
  Future<Either<Failure, bool>> adjustUserLoyaltyPoints({
    required int userId,
    required int pointsChange,
    required String reason,
  }) async {
    lastAdjustedLoyaltyUserId = userId;
    lastAdjustedLoyaltyPoints = pointsChange;
    lastAdjustedLoyaltyReason = reason;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      final u = users[idx];
      users[idx] = u.copyWith(loyaltyPoints: u.loyaltyPoints + pointsChange);
    }
    return const Right(true);
  }

  // ── Payments & Transactions Methods ──────────────────────────────────────
  @override
  Future<Either<Failure, List<AdminPaymentTransactionEntity>>> getPaymentTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(paymentTransactions);
  }

  @override
  Future<Either<Failure, List<AdminLoyaltyTransactionEntity>>> getLoyaltyTransactions({
    int? customerId,
    int limit = 20,
    int offset = 0,
  }) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(loyaltyTransactions);
  }

  // ── Settings Methods ─────────────────────────────────────────────────────
  @override
  Future<Either<Failure, AdminLoyaltySettingsEntity>> getLoyaltySettings() async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(loyaltySettings);
  }

  @override
  Future<Either<Failure, AdminLoyaltySettingsEntity>> updateLoyaltySettings({
    required double earningRate,
    required double redemptionRate,
    required int minRedemption,
  }) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    loyaltySettings = AdminLoyaltySettingsEntity(
      earningRate: earningRate,
      redemptionRate: redemptionRate,
      minRedemption: minRedemption,
    );
    lastUpdatedLoyaltySettings = loyaltySettings;
    return Right(loyaltySettings);
  }

  // ── Dashboard Stats ──────────────────────────────────────────────────────
  @override
  Future<Either<Failure, AdminDashboardStats>> getDashboardStats() async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(dashboardStats);
  }

  // ── Branches Implementation ───────────────────────────────────────────────
  @override
  Future<Either<Failure, List<BranchEntity>>> getAdminBranches({bool includeInactive = true}) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(includeInactive ? branches : branches.where((b) => b.isActive).toList());
  }

  @override
  Future<Either<Failure, BranchEntity>> createBranch(Map<String, dynamic> data) async {
    lastCreatedBranchPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final newBranch = BranchEntity(
      id: 100 + branches.length,
      name: data['name'] ?? data['name_ar'] ?? '',
      code: data['code'],
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      phone: data['phone'],
      openingHours: data['opening_hours'],
      isActive: data['active'] ?? data['is_active'] ?? true,
    );
    branches.add(newBranch);
    return Right(newBranch);
  }

  @override
  Future<Either<Failure, BranchEntity>> updateBranch(int id, Map<String, dynamic> data) async {
    lastUpdatedBranchId = id;
    lastUpdatedBranchPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = branches.indexWhere((b) => b.id == id);
    if (idx >= 0) {
      final updated = branches[idx].copyWith(
        name: data['name'] ?? data['name_ar'],
        code: data['code'],
        address: data['address'],
        city: data['city'],
        phone: data['phone'],
        openingHours: data['opening_hours'],
        isActive: data['active'] ?? data['is_active'],
      );
      branches[idx] = updated;
      return Right(updated);
    }
    return Left(mockFailure('الفرع غير موجود'));
  }

  @override
  Future<Either<Failure, void>> deleteBranch(int id) async {
    lastDeletedBranchId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    branches.removeWhere((b) => b.id == id);
    return const Right(null);
  }

  // ── Offers Implementation ─────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<OfferEntity>>> getAdminOffers({bool includeInactive = true}) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(includeInactive ? offers : offers.where((o) => o.isActive).toList());
  }

  @override
  Future<Either<Failure, OfferEntity>> createOffer(Map<String, dynamic> data) async {
    lastCreatedOfferPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final newOffer = OfferEntity(
      id: 200 + offers.length,
      name: data['name'] ?? '',
      subtitle: data['subtitle'],
      description: data['description'],
      discountType: data['discount_type'] ?? 'percentage',
      discountValue: (data['discount_value'] as num?)?.toDouble() ?? 10.0,
      badgeText: data['badge_text'] ?? 'خصم 10%',
      startDate: data['start_date'],
      endDate: data['end_date'],
      isActive: data['active'] ?? true,
      productIds: (data['product_ids'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [],
    );
    offers.add(newOffer);
    return Right(newOffer);
  }

  @override
  Future<Either<Failure, OfferEntity>> updateOffer(int id, Map<String, dynamic> data) async {
    lastUpdatedOfferPayload = data;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = offers.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      final updated = offers[idx].copyWith(
        name: data['name'],
        subtitle: data['subtitle'],
        description: data['description'],
        discountType: data['discount_type'],
        discountValue: (data['discount_value'] as num?)?.toDouble(),
        badgeText: data['badge_text'],
        startDate: data['start_date'],
        endDate: data['end_date'],
        isActive: data['active'],
        productIds: (data['product_ids'] as List?)?.map((e) => (e as num).toInt()).toList(),
      );
      offers[idx] = updated;
      return Right(updated);
    }
    return Left(mockFailure('العرض غير موجود'));
  }

  @override
  Future<Either<Failure, void>> deleteOffer(int id) async {
    lastDeletedOfferId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    offers.removeWhere((o) => o.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, OfferEntity>> toggleOfferActive(int id) async {
    lastToggledOfferId = id;
    if (shouldFail) return Left(mockFailure(failureMessage));
    final idx = offers.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      final updated = offers[idx].copyWith(isActive: !offers[idx].isActive);
      offers[idx] = updated;
      return Right(updated);
    }
    return Left(mockFailure('العرض غير موجود'));
  }

  // ── Contact Settings Implementation ───────────────────────────────────────
  @override
  Future<Either<Failure, AdminContactSettingsEntity>> getContactSettings() async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    return Right(contactSettings);
  }

  @override
  Future<Either<Failure, AdminContactSettingsEntity>> updateContactSettings({
    required String whatsappNumber,
    required String whatsappDefaultMessage,
    required bool whatsappEnabled,
    required String supportPhone,
  }) async {
    if (shouldFail) return Left(mockFailure(failureMessage));
    contactSettings = AdminContactSettingsEntity(
      whatsappNumber: whatsappNumber,
      whatsappDefaultMessage: whatsappDefaultMessage,
      whatsappEnabled: whatsappEnabled,
      supportPhone: supportPhone,
      deliveryFee: contactSettings.deliveryFee,
    );
    lastUpdatedContactSettings = contactSettings;
    return Right(contactSettings);
  }

  // ── Stubs for remaining interface methods ────────────────────────────────
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
