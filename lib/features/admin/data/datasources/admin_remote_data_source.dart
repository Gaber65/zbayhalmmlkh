import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/server_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/error_message_model.dart';
import '../../../user/catalog/data/models/category_model.dart';
import '../../../user/catalog/data/models/product_model.dart';
import '../../../user/catalog/domain/entities/category.dart';
import '../../../user/catalog/domain/entities/product.dart';
import '../../../user/orders/data/models/order_model.dart';
import '../../../user/orders/domain/entities/order_entity.dart';
import '../../../user/orders/domain/entities/branch_entity.dart';
import '../../../user/offers/domain/entities/offer_entity.dart';
import '../../../user/offers/data/models/offer_model.dart';
import '../../domain/entities/admin_entities.dart';

abstract class AdminRemoteDataSource {
  Future<AdminDashboardStats> getDashboardStats();
  Future<List<OrderListItemEntity>> getAdminOrders({
    String? state,
    String? query,
    int limit = 20,
    int offset = 0,
  });
  Future<OrderDetailEntity> getAdminOrderDetail(int orderId);
  Future<OrderDetailEntity> updateOrderStatus(int orderId, String newStatus);
  Future<List<Product>> getAdminProducts({
    String? query,
    int? categoryId,
    String? filter,
    int limit = 20,
    int offset = 0,
  });
  Future<Product> createProduct(Map<String, dynamic> data);
  Future<Product> updateProduct(int id, Map<String, dynamic> data);
  Future<void> deleteProduct(int id);
  Future<Product> toggleProductAvailability(int id, bool isAvailable);
  Future<List<Category>> getAdminCategories();
  Future<Category> createCategory(Map<String, dynamic> data);
  Future<Category> updateCategory(int id, Map<String, dynamic> data);
  Future<void> deleteCategory(int id);
  Future<List<AdminBannerEntity>> getAdminBanners();
  Future<AdminBannerEntity> createBanner(Map<String, dynamic> data);
  Future<AdminBannerEntity> updateBanner(int id, Map<String, dynamic> data);
  Future<void> deleteBanner(int id);
  Future<List<AdminOptionEntity>> getAdminOptions({String? type});
  Future<AdminOptionEntity> saveOption(Map<String, dynamic> data);
  Future<void> deleteOption(int id, {String? type});
  Future<List<AdminSizeEntity>> getAdminSizes({int? productId});
  Future<AdminSizeEntity> saveSize(Map<String, dynamic> data);
  Future<void> deleteSize(int id);
  Future<List<AdminCouponEntity>> getAdminCoupons();
  Future<AdminCouponEntity> createCoupon(Map<String, dynamic> data);
  Future<AdminCouponEntity> toggleCoupon(int id, bool isActive);
  Future<void> deleteCoupon(int id);
  Future<List<AdminNotificationEntity>> getNotifications();
  Future<void> markNotificationsRead({int? id, bool markAll = false});
  Future<bool> sendBroadcastNotification({
    required String title,
    required String body,
    String? topic,
  });

  // ─── 9. Users CRM ──────────────────────────────────────────────────────────
  Future<List<AdminUserEntity>> getAdminUsers({
    String? status,
    String? userType,
    String? query,
    int limit = 20,
    int offset = 0,
  });
  Future<AdminUserEntity> getAdminUserDetail(int userId);
  Future<AdminUserEntity> createAdminUser(Map<String, dynamic> data);
  Future<AdminUserEntity> updateAdminUser(int userId, Map<String, dynamic> data);
  Future<void> deleteAdminUser(int userId);
  Future<AdminUserEntity> updateAdminUserStatus(int userId, String status);
  Future<bool> adjustUserLoyaltyPoints({
    required int userId,
    required int pointsChange,
    required String reason,
  });

  // ─── 10. Highlights / Stories ──────────────────────────────────────────────
  Future<List<AdminHighlightEntity>> getAdminHighlights();
  Future<AdminHighlightEntity> createAdminHighlight(Map<String, dynamic> data);
  Future<void> deleteAdminHighlight(int id);

  // ─── 11. Payments & Loyalty Transactions ───────────────────────────────────
  Future<List<AdminPaymentTransactionEntity>> getPaymentTransactions({
    int limit = 20,
    int offset = 0,
  });
  Future<List<AdminLoyaltyTransactionEntity>> getLoyaltyTransactions({
    int? customerId,
    int limit = 20,
    int offset = 0,
  });
  Future<AdminLoyaltySettingsEntity> getLoyaltySettings();
  Future<AdminLoyaltySettingsEntity> updateLoyaltySettings({
    required double earningRate,
    required double redemptionRate,
    required int minRedemption,
  });

  // ─── 12. Branches Management ──────────────────────────────────────────────
  Future<List<BranchEntity>> getAdminBranches({bool includeInactive = true});
  Future<BranchEntity> createBranch(Map<String, dynamic> data);
  Future<BranchEntity> updateBranch(int id, Map<String, dynamic> data);
  Future<void> deleteBranch(int id);

  // ─── 13. Offers Management ────────────────────────────────────────────────
  Future<List<OfferEntity>> getAdminOffers({bool includeInactive = true});
  Future<OfferEntity> createOffer(Map<String, dynamic> data);
  Future<OfferEntity> updateOffer(int id, Map<String, dynamic> data);
  Future<void> deleteOffer(int id);
  Future<OfferEntity> toggleOfferActive(int id);

  // ─── 14. Contact & WhatsApp Settings ──────────────────────────────────────
  Future<AdminContactSettingsEntity> getContactSettings();
  Future<AdminContactSettingsEntity> updateContactSettings({
    required String whatsappNumber,
    required String whatsappDefaultMessage,
    required bool whatsappEnabled,
    required String supportPhone,
  });
}

@LazySingleton(as: AdminRemoteDataSource)
class AdminRemoteDataSourceImpl
    with DioErrorHandler
    implements AdminRemoteDataSource {
  final Dio dio;

  AdminRemoteDataSourceImpl({required this.dio});

  // ─── 1. Dashboard Analytics ───────────────────────────────────────────────
  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final response = await dio.get(ServerStrings.dashboardStats);
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data['data'] ?? response.data;
        final dynamic kpi = resData is Map && resData.containsKey('kpi_data')
            ? resData['kpi_data']
            : (resData is Map && resData.containsKey('kpi')
                ? resData['kpi']
                : resData);
        if (kpi is Map) {
          final recentList = resData is Map && resData['recent_orders'] is List
              ? List<Map<String, dynamic>>.from(resData['recent_orders'])
              : <Map<String, dynamic>>[];
          final topList = resData is Map && resData['top_products'] is List
              ? List<Map<String, dynamic>>.from(resData['top_products'])
              : <Map<String, dynamic>>[];
          final sales = resData is Map && resData['sales_data'] is Map
              ? Map<String, dynamic>.from(resData['sales_data'])
              : <String, dynamic>{};
          final inventory = resData is Map && resData['inventory_data'] is Map
              ? Map<String, dynamic>.from(resData['inventory_data'])
              : <String, dynamic>{};

          return AdminDashboardStats(
            totalOrders: (kpi['total_orders'] as num?)?.toInt() ?? 0,
            pendingOrders: (kpi['pending_orders'] as num?)?.toInt() ?? 0,
            preparingOrders: (kpi['preparing_orders'] as num?)?.toInt() ?? 0,
            deliveringOrders: (kpi['delivering_orders'] as num?)?.toInt() ?? 0,
            completedOrders: (kpi['completed_orders'] as num?)?.toInt() ?? 0,
            cancelledOrders: (kpi['cancelled_orders'] as num?)?.toInt() ?? 0,
            todaySales:
                (kpi['current_month_revenue'] as num?)?.toDouble() ?? 0.0,
            monthlySales: (kpi['total_revenue'] as num?)?.toDouble() ?? 0.0,
            totalProducts: (kpi['total_products'] as num?)?.toInt() ?? 0,
            lowStockCount: (kpi['low_stock'] as num?)?.toInt() ?? 0,
            totalCustomers: (kpi['total_customers'] as num?)?.toInt() ?? 0,
            ordersProgress: (kpi['orders_progress'] as num?)?.toInt() ?? 0,
            revenueProgress: (kpi['revenue_progress'] as num?)?.toInt() ?? 0,
            customersProgress:
                (kpi['customers_progress'] as num?)?.toInt() ?? 0,
            pendingProgress: (kpi['pending_progress'] as num?)?.toInt() ?? 0,
            lowStockProgress: (kpi['low_stock_progress'] as num?)?.toInt() ?? 0,
            currentMonthRevenue:
                (kpi['current_month_revenue'] as num?)?.toDouble() ?? 0.0,
            currentMonthOrders:
                (kpi['current_month_orders'] as num?)?.toInt() ?? 0,
            currentMonthCustomers:
                (kpi['current_month_customers'] as num?)?.toInt() ?? 0,
            recentOrders: recentList,
            topProducts: topList,
            salesData: sales,
            inventoryData: inventory,
          );
        }
      }
    } catch (_) {
      // Fallback: calculate live stats from real orders & products API
    }

    try {
      final orders = await getAdminOrders();
      final products = await getAdminProducts();

      final pendingCount = orders
          .where((o) => o.state == 'pending_payment' || o.state == 'draft')
          .length;
      final preparingCount = orders
          .where((o) => o.state == 'confirmed' || o.state == 'preparing')
          .length;
      final deliveringCount = orders
          .where(
            (o) => o.state == 'out_delivery' || o.state == 'out_for_delivery',
          )
          .length;
      final completedCount = orders.where((o) => o.state == 'delivered').length;
      final cancelledCount = orders.where((o) => o.state == 'cancelled').length;
      final totalSales = orders
          .where((o) => o.state != 'cancelled')
          .fold(0.0, (sum, o) => sum + o.total);

      return AdminDashboardStats(
        totalOrders: orders.length,
        pendingOrders: pendingCount,
        preparingOrders: preparingCount,
        deliveringOrders: deliveringCount,
        completedOrders: completedCount,
        cancelledOrders: cancelledCount,
        todaySales: totalSales,
        monthlySales: totalSales,
        totalProducts: products.length,
        lowStockCount: products
            .where((p) => (p.stockQuantity ?? 0) <= 3)
            .length,
        totalCustomers: 0,
      );
    } catch (_) {
      return const AdminDashboardStats(
        totalOrders: 0,
        pendingOrders: 0,
        preparingOrders: 0,
        deliveringOrders: 0,
        completedOrders: 0,
        cancelledOrders: 0,
        todaySales: 0.0,
        monthlySales: 0.0,
        totalProducts: 0,
        lowStockCount: 0,
        totalCustomers: 0,
      );
    }
  }

  // ─── 2. Orders Management ──────────────────────────────────────────────────
  @override
  Future<List<OrderListItemEntity>> getAdminOrders({
    String? state,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        ServerStrings.orders,
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (state != null && state.isNotEmpty && state != 'all')
            'state': state,
          if (query != null && query.isNotEmpty) 'search': query,
        },
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        if (data is List) {
          final orders = data
              .map(
                (e) => OrderListItemModel.fromJson(
                  e as Map<String, dynamic>,
                ).toDomain(),
              )
              .toList();
          return orders;
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<OrderDetailEntity> getAdminOrderDetail(int orderId) async {
    try {
      final response = await dio.get(ServerStrings.orderById(orderId));
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return OrderDetailModel.fromJson(
          data as Map<String, dynamic>,
        ).toDomain();
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<OrderDetailEntity> updateOrderStatus(
    int orderId,
    String newStatus,
  ) async {
    Response? response;
    final payload = {'status': newStatus, 'state': newStatus};

    // 1. Try POST /api/v1/orders/$orderId/status
    try {
      response = await dio.post(
        ServerStrings.updateOrderStatus(orderId),
        data: payload,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // 2. Fallback: Try PUT /api/v1/orders/$orderId
        try {
          response = await dio.put(
            ServerStrings.orderById(orderId),
            data: payload,
          );
        } on DioException catch (e2) {
          if (e2.response?.statusCode == 404) {
            // 3. Fallback: Try POST /api/v1/admin/orders/$orderId/status
            try {
              response = await dio.post(
                '/api/v1/admin/orders/$orderId/status',
                data: payload,
              );
            } on DioException catch (e3) {
              if (newStatus == 'cancelled') {
                try {
                  await dio.post(ServerStrings.cancelOrder(orderId));
                } catch (_) {}
              } else if (newStatus == 'delivered') {
                try {
                  await dio.post(ServerStrings.receiveOrder(orderId));
                } catch (_) {}
              } else {
                throw handleDioError(e3);
              }
            }
          } else {
            throw handleDioError(e2);
          }
        }
      } else {
        throw handleDioError(e);
      }
    }

    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      final dynamic data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return OrderDetailModel.fromJson(data).toDomain();
      }
    }
    return await getAdminOrderDetail(orderId);
  }

  // ─── 3. Products CRUD ─────────────────────────────────────────────────────
  @override
  Future<List<Product>> getAdminProducts({
    String? query,
    int? categoryId,
    String? filter,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        ServerStrings.products,
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (query != null && query.isNotEmpty) 'search': query,
          if (categoryId != null && categoryId > 0) 'category_id': categoryId,
          if (filter != null && filter.isNotEmpty && filter != 'all') 'filter': filter,
        },
      );
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'] ?? response.data;
        final dynamic list = responseData is Map
            ? (responseData['data'] ?? responseData['products'] ?? responseData['items'])
            : responseData;
        if (list is List) {
          final products = list
              .map((e) => ProductModel.fromJson(e).toDomain())
              .toList();
          return products;
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Product> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ServerStrings.products, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic resData = response.data['data'] ?? response.data;
        return ProductModel.fromJson(
          resData as Map<String, dynamic>,
        ).toDomain();
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(ServerStrings.productById(id), data: data);
      if (response.statusCode == 200) {
        final dynamic resData = response.data['data'] ?? response.data;
        return ProductModel.fromJson(
          resData as Map<String, dynamic>,
        ).toDomain();
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await dio.delete(ServerStrings.productById(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Product> toggleProductAvailability(int id, bool isAvailable) async {
    try {
      await dio.post(
        ServerStrings.toggleProductActive(id),
        data: {'is_available': isAvailable, 'active': isAvailable},
      );
    } catch (_) {}
    return updateProduct(id, {
      'is_available': isAvailable,
      'active': isAvailable,
    });
  }

  // ─── 4. Categories CRUD ───────────────────────────────────────────────────
  @override
  Future<List<Category>> getAdminCategories() async {
    try {
      final response = await dio.get(ServerStrings.catalogCategories);
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        final dynamic list = data is Map
            ? (data['data'] ?? data['categories'])
            : data;
        if (list is List) {
          return list.map((e) => CategoryModel.fromJson(e).toDomain()).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ServerStrings.categories, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic resData = response.data['data'] ?? response.data;
        return CategoryModel.fromJson(
          resData as Map<String, dynamic>,
        ).toDomain();
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        ServerStrings.categoryById(id),
        data: data,
      );
      if (response.statusCode == 200) {
        final dynamic resData = response.data['data'] ?? response.data;
        return CategoryModel.fromJson(
          resData as Map<String, dynamic>,
        ).toDomain();
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await dio.delete(ServerStrings.categoryById(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 5. Banners CRUD ──────────────────────────────────────────────────────
  @override
  Future<List<AdminBannerEntity>> getAdminBanners() async {
    try {
      final response = await dio.get(ServerStrings.banners);
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        final dynamic list = data is Map
            ? (data['banners'] ?? data['data'])
            : data;
        if (list is List) {
          return list
              .map(
                (e) => AdminBannerEntity(
                  id: e['id'] ?? 0,
                  title: e['name'] ?? e['title'] ?? '',
                  imageUrl: e['image_url'] ?? e['image'] ?? '',
                  link: e['link'],
                  isActive: e['is_active'] ?? e['active'] ?? true,
                  displayOrder: e['sequence'] ?? 0,
                ),
              )
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AdminBannerEntity> createBanner(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ServerStrings.banners, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic res = response.data['data'] ?? response.data;
        return AdminBannerEntity(
          id: res['id'] ?? 0,
          title: res['name'] ?? res['title'] ?? data['title'] ?? '',
          imageUrl: res['image_url'] ?? res['image'] ?? data['image_url'] ?? '',
          link: res['link'] ?? data['link'],
          isActive: res['is_active'] ?? res['active'] ?? true,
          displayOrder: res['sequence'] ?? 0,
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AdminBannerEntity> updateBanner(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(ServerStrings.bannerById(id), data: data);
      if (response.statusCode == 200) {
        final dynamic res = response.data['data'] ?? response.data;
        return AdminBannerEntity(
          id: res['id'] ?? id,
          title: res['name'] ?? res['title'] ?? data['title'] ?? '',
          imageUrl: res['image_url'] ?? res['image'] ?? data['image_url'] ?? '',
          link: res['link'] ?? data['link'],
          isActive: res['is_active'] ?? res['active'] ?? true,
          displayOrder: res['sequence'] ?? 0,
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteBanner(int id) async {
    try {
      await dio.delete(ServerStrings.bannerById(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 6. Customization Options CRUD ────────────────────────────────────────
  @override
  Future<List<AdminOptionEntity>> getAdminOptions({String? type}) async {
    final results = <AdminOptionEntity>[];

    try {
      if (type == null || type == 'cutting') {
        final res = await dio.get(ServerStrings.catalogCuttingOptions);
        if (res.statusCode == 200) {
          final dynamic data = res.data['data'] ?? res.data;
          final dynamic list = data is Map
              ? (data['cutting_options'] ?? data['data'])
              : data;
          if (list is List) {
            results.addAll(
              list.map(
                (e) => AdminOptionEntity(
                  id: e['id'] ?? 0,
                  name: e['name'] ?? '',
                  description: e['description'],
                  extraPrice: (e['extra_price'] as num?)?.toDouble() ?? 0.0,
                  type: 'cutting',
                  isActive: e['active'] ?? e['is_active'] ?? true,
                ),
              ),
            );
          }
        }
      }

      if (type == null || type == 'packaging') {
        final res = await dio.get(ServerStrings.catalogPackagings);
        if (res.statusCode == 200) {
          final dynamic data = res.data['data'] ?? res.data;
          final dynamic list = data is Map
              ? (data['packagings'] ?? data['data'])
              : data;
          if (list is List) {
            results.addAll(
              list.map(
                (e) => AdminOptionEntity(
                  id: e['id'] ?? 0,
                  name: e['name'] ?? '',
                  description: e['description'],
                  extraPrice: (e['extra_price'] as num?)?.toDouble() ?? 0.0,
                  type: 'packaging',
                  isActive: e['active'] ?? e['is_active'] ?? true,
                ),
              ),
            );
          }
        }
      }

      if (type == null || type == 'excluded_part' || type == 'excluded') {
        final res = await dio.get(ServerStrings.catalogExcludedParts);
        if (res.statusCode == 200) {
          final dynamic data = res.data['data'] ?? res.data;
          final dynamic list = data is Map
              ? (data['excluded_parts'] ?? data['data'])
              : data;
          if (list is List) {
            results.addAll(
              list.map(
                (e) => AdminOptionEntity(
                  id: e['id'] ?? 0,
                  name: e['name'] ?? '',
                  description: e['description'],
                  extraPrice: (e['extra_price'] as num?)?.toDouble() ?? 0.0,
                  type: 'excluded_part',
                  isActive: e['active'] ?? e['is_active'] ?? true,
                ),
              ),
            );
          }
        }
      }
    } catch (_) {}

    return results;
  }

  @override
  Future<AdminOptionEntity> saveOption(Map<String, dynamic> data) async {
    try {
      final id = data['id'] as int?;
      final type = data['type'] ?? 'cutting';
      String endpoint;
      if (type == 'packaging') {
        endpoint = id != null && id > 0
            ? ServerStrings.packagingById(id)
            : ServerStrings.packagings;
      } else if (type == 'excluded_part' || type == 'excluded') {
        endpoint = id != null && id > 0
            ? ServerStrings.excludedPartById(id)
            : ServerStrings.excludedParts;
      } else {
        endpoint = id != null && id > 0
            ? ServerStrings.cuttingOptionById(id)
            : ServerStrings.cuttingOptions;
      }

      Response response;
      if (id != null && id > 0) {
        response = await dio.put(endpoint, data: data);
      } else {
        response = await dio.post(endpoint, data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic res = response.data['data'] ?? response.data;
        return AdminOptionEntity(
          id: res['id'] ?? id ?? 0,
          name: res['name'] ?? data['name'] ?? '',
          description: res['description'] ?? data['description'],
          extraPrice:
              (res['extra_price'] as num?)?.toDouble() ??
              (data['extra_price'] as num?)?.toDouble() ??
              0.0,
          type: type,
          isActive:
              res['active'] ?? res['is_active'] ?? data['is_active'] ?? true,
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteOption(int id, {String? type}) async {
    try {
      String endpoint;
      if (type == 'packaging') {
        endpoint = ServerStrings.packagingById(id);
      } else if (type == 'excluded_part' || type == 'excluded') {
        endpoint = ServerStrings.excludedPartById(id);
      } else {
        endpoint = ServerStrings.cuttingOptionById(id);
      }
      await dio.delete(endpoint);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 6.1 Product Carcass Sizes CRUD ───────────────────────────────────────
  @override
  Future<List<AdminSizeEntity>> getAdminSizes({int? productId}) async {
    try {
      final response = await dio.get(
        ServerStrings.sizes,
        queryParameters: {
          if (productId != null) 'product_id': productId,
          'limit': 100,
        },
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        final dynamic list = data is Map ? (data['data'] ?? data['sizes']) : data;
        if (list is List) {
          return list.map((e) => AdminSizeEntity.fromMap(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AdminSizeEntity> saveSize(Map<String, dynamic> data) async {
    try {
      final id = data['id'] as int?;
      Response response;
      if (id != null && id > 0) {
        response = await dio.put(ServerStrings.sizeById(id), data: data);
      } else {
        response = await dio.post(ServerStrings.sizes, data: data);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic res = response.data['data'] ?? response.data;
        return AdminSizeEntity.fromMap(res as Map<String, dynamic>);
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteSize(int id) async {
    try {
      await dio.delete(ServerStrings.sizeById(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 7. Coupons CRUD ──────────────────────────────────────────────────────
  @override
  Future<List<AdminCouponEntity>> getAdminCoupons() async {
    try {
      final response = await dio.get(ServerStrings.coupons);
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        final dynamic list = data is Map
            ? (data['coupons'] ?? data['data'])
            : data;
        if (list is List) {
          return list
              .map(
                (e) => AdminCouponEntity(
                  id: e['id'] ?? 0,
                  code: e['code'] ?? '',
                  discountType: e['discount_type'] ?? 'percentage',
                  discountValue:
                      (e['discount_value'] as num?)?.toDouble() ?? 0.0,
                  minOrderValue:
                      (e['min_order_value'] as num?)?.toDouble() ??
                      (e['minimum_order_amount'] as num?)?.toDouble() ??
                      0.0,
                  maxDiscount: (e['max_discount'] as num?)?.toDouble() ??
                      (e['maximum_discount'] as num?)?.toDouble(),
                  maxUses: (e['max_uses'] ?? e['usage_limit']) as int?,
                  currentUses:
                      (e['current_uses'] ?? e['used_count']) as int? ?? 0,
                  expiryDate: e['expiry_date'] ?? e['end_date'] ?? '',
                  isActive: e['active'] ?? e['is_active'] ?? true,
                ),
              )
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AdminCouponEntity> createCoupon(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ServerStrings.coupons, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic res = response.data['data'] ?? response.data;
        return AdminCouponEntity(
          id: res['id'] ?? 0,
          code: res['code'] ?? data['code'] ?? '',
          discountType:
              res['discount_type'] ?? data['discount_type'] ?? 'percentage',
          discountValue:
              (res['discount_value'] as num?)?.toDouble() ??
              (data['discount_value'] as num?)?.toDouble() ??
              0.0,
          minOrderValue:
              (res['min_order_value'] as num?)?.toDouble() ??
              (data['min_order_value'] as num?)?.toDouble() ??
              0.0,
          maxDiscount:
              (res['max_discount'] as num?)?.toDouble() ??
              (data['max_discount'] as num?)?.toDouble(),
          maxUses: res['max_uses'] as int? ?? data['max_uses'] as int?,
          currentUses: 0,
          expiryDate: res['expiry_date'] ?? data['expiry_date'] ?? '',
          isActive: true,
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AdminCouponEntity> toggleCoupon(int id, bool isActive) async {
    try {
      final response = await dio.post(
        '/api/v1/coupons/$id/toggle-active',
        data: {'is_active': isActive},
      );
      if (response.statusCode == 200) {
        final dynamic res = response.data['data'] ?? response.data;
        return AdminCouponEntity(
          id: res['id'] ?? id,
          code: res['code'] ?? '',
          discountType: res['discount_type'] ?? 'percentage',
          discountValue: (res['discount_value'] as num?)?.toDouble() ?? 0.0,
          minOrderValue: (res['min_order_value'] as num?)?.toDouble() ?? 0.0,
          maxDiscount: (res['max_discount'] as num?)?.toDouble(),
          maxUses: res['max_uses'] as int?,
          currentUses: res['current_uses'] as int? ?? 0,
          expiryDate: res['expiry_date'] ?? '',
          isActive: isActive,
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteCoupon(int id) async {
    try {
      await dio.delete(ServerStrings.couponById(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 8. Notifications ──────────────────────────────────────────────────────
  @override
  Future<List<AdminNotificationEntity>> getNotifications() async {
    try {
      final response = await dio.get(ServerStrings.notifications);
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        final dynamic list = data is Map ? (data['notifications'] ?? data['items'] ?? data['list']) : data;
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => AdminNotificationEntity.fromJson(e))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> markNotificationsRead({int? id, bool markAll = false}) async {
    try {
      final Map<String, dynamic> payload = {'mark_all': markAll};
      if (id != null) {
        payload['notification_id'] = id;
      }
      await dio.post(
        ServerStrings.readNotification,
        data: payload,
      );
    } catch (_) {}
  }

  @override
  Future<bool> sendBroadcastNotification({
    required String title,
    required String body,
    String? topic,
  }) async {
    try {
      final response = await dio.post(
        ServerStrings.adminBroadcastNotification,
        data: {'title': title, 'body': body, 'topic': topic ?? 'topic:all'},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 9. Users CRM ──────────────────────────────────────────────────────────
  @override
  Future<List<AdminUserEntity>> getAdminUsers({
    String? status,
    String? userType,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        if (status != null && status.isNotEmpty && status != 'all') 'status': status,
        if (userType != null && userType.isNotEmpty && userType != 'all') 'user_type': userType,
        if (query != null && query.isNotEmpty) 'search': query,
      };

      final response = await dio.get(
        '/api/v1/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        final dynamic list = data is Map ? (data['users'] ?? data['data']) : data;
        if (list is List) {
          return list.map((e) {
            final map = e as Map<String, dynamic>;
            return AdminUserEntity(
              id: map['id'] ?? 0,
              name: map['name'] ?? '',
              email: map['email'] ?? '',
              phone: map['phone']?.toString(),
              status: map['status'] ?? (map['is_active'] == true ? 'active' : 'suspended'),
              userType: map['user_type'] ?? 'individual',
              totalOrdersCount: (map['total_orders_count'] ?? map['total_orders'] as num?)?.toInt() ?? 0,
              totalSpending: (map['total_spending'] ?? map['total_spent'] as num?)?.toDouble() ?? 0.0,
              totalRefunds: (map['total_refunds'] as num?)?.toDouble() ?? 0.0,
              loyaltyPoints: (map['loyalty_points'] as num?)?.toInt() ?? 0,
              createDate: map['create_date']?.toString(),
              addresses: map['addresses'] is List
                  ? List<Map<String, dynamic>>.from(map['addresses'])
                  : [],
            );
          }).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AdminUserEntity> getAdminUserDetail(int userId) async {
    try {
      final response = await dio.get('/api/v1/admin/users/$userId');
      if (response.statusCode == 200) {
        final dynamic map = response.data['data'] ?? response.data;
        return AdminUserEntity(
          id: map['id'] ?? userId,
          name: map['name'] ?? '',
          email: map['email'] ?? '',
          phone: map['phone']?.toString(),
          status: map['status'] ?? (map['is_active'] == true ? 'active' : 'suspended'),
          userType: map['user_type'] ?? 'individual',
          totalOrdersCount: (map['total_orders_count'] ?? map['total_orders'] as num?)?.toInt() ?? 0,
          totalSpending: (map['total_spending'] ?? map['total_spent'] as num?)?.toDouble() ?? 0.0,
          totalRefunds: (map['total_refunds'] as num?)?.toDouble() ?? 0.0,
          loyaltyPoints: (map['loyalty_points'] as num?)?.toInt() ?? 0,
          createDate: map['create_date']?.toString(),
          addresses: map['addresses'] is List
              ? List<Map<String, dynamic>>.from(map['addresses'])
              : [],
          averageOrderValue: (map['average_order_value'] as num?)?.toDouble() ?? 0.0,
          totalEarnedPoints: (map['total_earned_points'] as num?)?.toInt() ?? 0,
          totalRedeemedPoints: (map['total_redeemed_points'] as num?)?.toInt() ?? 0,
          lastLogin: map['last_login']?.toString(),
          lastActivityDate: map['last_activity_date']?.toString(),
          verifiedAt: map['verified_at']?.toString(),
          profileCompleted: map['profile_completed'] == true,
          balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
          currency: map['currency']?.toString() ?? 'SAR',
          orders: map['orders'] is List
              ? List<Map<String, dynamic>>.from(map['orders'])
              : [],
          loyaltyTransactions: map['loyalty_transactions'] is List
              ? List<Map<String, dynamic>>.from(map['loyalty_transactions'])
              : [],
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AdminUserEntity> createAdminUser(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/api/v1/admin/users', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic map = response.data['data'] ?? response.data;
        return AdminUserEntity(
          id: map['id'] ?? 0,
          name: map['name'] ?? '',
          email: map['email'] ?? '',
          phone: map['phone']?.toString(),
          status: map['status'] ?? 'active',
          userType: map['user_type'] ?? 'individual',
          totalOrdersCount: (map['total_orders_count'] as num?)?.toInt() ?? 0,
          totalSpending: (map['total_spending'] as num?)?.toDouble() ?? 0.0,
          totalRefunds: (map['total_refunds'] as num?)?.toDouble() ?? 0.0,
          loyaltyPoints: (map['loyalty_points'] as num?)?.toInt() ?? 0,
          createDate: map['create_date']?.toString(),
          addresses: const [],
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AdminUserEntity> updateAdminUser(int userId, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/api/v1/admin/users/$userId', data: data);
      if (response.statusCode == 200) {
        final dynamic map = response.data['data'] ?? response.data;
        return AdminUserEntity(
          id: map['id'] ?? userId,
          name: map['name'] ?? '',
          email: map['email'] ?? '',
          phone: map['phone']?.toString(),
          status: map['status'] ?? 'active',
          userType: map['user_type'] ?? 'individual',
          totalOrdersCount: (map['total_orders_count'] as num?)?.toInt() ?? 0,
          totalSpending: (map['total_spending'] as num?)?.toDouble() ?? 0.0,
          totalRefunds: (map['total_refunds'] as num?)?.toDouble() ?? 0.0,
          loyaltyPoints: (map['loyalty_points'] as num?)?.toInt() ?? 0,
          createDate: map['create_date']?.toString(),
          addresses: map['addresses'] is List
              ? List<Map<String, dynamic>>.from(map['addresses'])
              : [],
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteAdminUser(int userId) async {
    try {
      final response = await dio.delete('/api/v1/admin/users/$userId');
      if (response.statusCode != 200) {
        throw ServerException(
          errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
        );
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AdminUserEntity> updateAdminUserStatus(int userId, String status) async {
    try {
      final response = await dio.put(
        '/api/v1/admin/users/$userId/status',
        data: {'status': status, 'active': status == 'active'},
      );
      if (response.statusCode == 200) {
        return getAdminUserDetail(userId);
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<bool> adjustUserLoyaltyPoints({
    required int userId,
    required int pointsChange,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/api/v1/loyalty/adjust',
        data: {
          'customer_id': userId,
          'points_change': pointsChange,
          'reason': reason,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 10. Highlights / Stories ──────────────────────────────────────────────
  @override
  Future<List<AdminHighlightEntity>> getAdminHighlights() async {
    try {
      final response = await dio.get('/api/v1/highlights');
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        final dynamic list = data is Map ? (data['highlights'] ?? data['data']) : data;
        if (list is List) {
          return list.map((e) {
            final map = e as Map<String, dynamic>;
            return AdminHighlightEntity(
              id: map['id'] ?? 0,
              mediaUrl: map['media_url'] ?? map['url'] ?? map['image_url'] ?? '',
              mediaType: map['media_type'] ?? 'image',
              title: map['title'] ?? map['name'],
              createdAt: map['created_at']?.toString(),
              isViewed: map['is_viewed'] ?? false,
            );
          }).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AdminHighlightEntity> createAdminHighlight(Map<String, dynamic> data) async {
    try {
      dynamic postData = data;
      Options? options;
      if (data['image_path'] != null && (data['image_path'] as String).isNotEmpty) {
        final path = data['image_path'] as String;
        final formData = FormData.fromMap({
          'media_type': data['media_type'] ?? 'image',
          if (data['title'] != null && (data['title'] as String).isNotEmpty)
            'name': data['title'],
          'media': await MultipartFile.fromFile(
            path,
            filename: path.split(RegExp(r'[/\\]')).last,
          ),
        });
        postData = formData;
        options = Options(contentType: 'multipart/form-data');
      }

      final response = await dio.post('/api/v1/highlights', data: postData, options: options);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic map = response.data['data'] ?? response.data;
        return AdminHighlightEntity(
          id: map['id'] ?? 0,
          mediaUrl: map['media_url'] ?? data['media_url'] ?? '',
          mediaType: map['media_type'] ?? data['media_type'] ?? 'image',
          title: map['title'] ?? data['title'],
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteAdminHighlight(int id) async {
    try {
      await dio.delete('/api/v1/highlights/$id');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 11. Payments & Loyalty Transactions ───────────────────────────────────
  @override
  Future<List<AdminPaymentTransactionEntity>> getPaymentTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        ServerStrings.orders,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        if (data is List) {
          return data.map((e) {
            final map = e as Map<String, dynamic>;
            final paymentMethod = map['payment_method']?.toString() ?? 'Cash on Delivery';
            final isInstallment = paymentMethod.toLowerCase().contains('tabby') ||
                paymentMethod.toLowerCase().contains('tamara');
            final installmentProvider = paymentMethod.toLowerCase().contains('tabby')
                ? 'Tabby'
                : (paymentMethod.toLowerCase().contains('tamara') ? 'Tamara' : null);

            return AdminPaymentTransactionEntity(
              id: map['id'] ?? 0,
              orderName: map['name'] ?? 'JAB-ORD-${map['id']}',
              customerName: map['customer_name'] ?? map['partner_name'] ?? 'Customer',
              paymentMethod: paymentMethod,
              amount: (map['total'] ?? map['amount_total'] ?? 0.0).toDouble(),
              status: map['payment_status'] ?? (map['state'] == 'delivered' ? 'Paid' : 'Pending'),
              transactionReference: map['transaction_reference'] ?? 'TX-${map['id']}',
              paidDate: map['date']?.toString(),
              isInstallment: isInstallment,
              installmentProvider: installmentProvider,
            );
          }).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<AdminLoyaltyTransactionEntity>> getLoyaltyTransactions({
    int? customerId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        '/api/v1/loyalty/transactions',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'customer_id': ?customerId,
        },
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        if (data is List) {
          return data.map((e) {
            final map = e as Map<String, dynamic>;
            return AdminLoyaltyTransactionEntity(
              id: map['id'] ?? 0,
              date: map['date']?.toString() ?? map['create_date']?.toString() ?? '',
              customerName: map['customer_name'] ?? map['user_name'] ?? 'User',
              transactionType: map['transaction_type'] ?? map['type'] ?? 'earn',
              points: map['points'] ?? map['points_change'] ?? 0,
              balanceAfter: map['balance_after'] ?? map['new_balance'] ?? 0,
              orderName: map['order_name'] ?? map['order_reference'],
              description: map['description'] ?? map['reason'] ?? '',
              createdBy: map['created_by'] ?? 'System',
            );
          }).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AdminLoyaltySettingsEntity> getLoyaltySettings() async {
    try {
      final response = await dio.get('/api/v1/loyalty/settings');
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return AdminLoyaltySettingsEntity(
          earningRate: (data['earning_rate'] ?? 1.0).toDouble(),
          redemptionRate: (data['redemption_rate'] ?? 100.0).toDouble(),
          minRedemption: (data['min_redemption'] ?? 500).toInt(),
        );
      }
      return const AdminLoyaltySettingsEntity(
        earningRate: 1.0,
        redemptionRate: 100.0,
        minRedemption: 500,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return const AdminLoyaltySettingsEntity(
        earningRate: 1.0,
        redemptionRate: 100.0,
        minRedemption: 500,
      );
    }
  }

  @override
  Future<AdminLoyaltySettingsEntity> updateLoyaltySettings({
    required double earningRate,
    required double redemptionRate,
    required int minRedemption,
  }) async {
    try {
      final response = await dio.put('/api/v1/loyalty/settings', data: {
        'earning_rate': earningRate,
        'redemption_rate': redemptionRate,
        'min_redemption': minRedemption,
      });
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return AdminLoyaltySettingsEntity(
          earningRate: (data['earning_rate'] ?? earningRate).toDouble(),
          redemptionRate: (data['redemption_rate'] ?? redemptionRate).toDouble(),
          minRedemption: (data['min_redemption'] ?? minRedemption).toInt(),
        );
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 12. Branches Management ──────────────────────────────────────────────
  @override
  Future<List<BranchEntity>> getAdminBranches({bool includeInactive = true}) async {
    try {
      final response = await dio.get(
        ServerStrings.branches,
        queryParameters: includeInactive ? {'all': 'true'} : null,
      );
      if (response.statusCode == 200) {
        final dynamic raw = response.data['data'] ?? response.data;
        if (raw is List) {
          return raw
              .map((b) => BranchEntity.fromJson(Map<String, dynamic>.from(b as Map)))
              .toList();
        }
        return [];
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<BranchEntity> createBranch(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ServerStrings.branches, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic resData = response.data['data'] ?? response.data;
        return BranchEntity.fromJson(Map<String, dynamic>.from(resData as Map));
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<BranchEntity> updateBranch(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(ServerStrings.branchById(id), data: data);
      if (response.statusCode == 200) {
        final dynamic resData = response.data['data'] ?? response.data;
        return BranchEntity.fromJson(Map<String, dynamic>.from(resData as Map));
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteBranch(int id) async {
    try {
      final response = await dio.delete(ServerStrings.branchById(id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 13. Offers Management ────────────────────────────────────────────────
  @override
  Future<List<OfferEntity>> getAdminOffers({bool includeInactive = true}) async {
    try {
      final response = await dio.get(
        ServerStrings.offers,
        queryParameters: includeInactive ? {'all': 'true'} : null,
      );
      if (response.statusCode == 200) {
        final dynamic resData = response.data['data'] ?? response.data;
        final dynamic rawOffers = (resData is Map) ? resData['offers'] : resData;
        if (rawOffers is List) {
          return rawOffers
              .map((o) => OfferModel.fromJson(Map<String, dynamic>.from(o as Map)).toDomain())
              .toList();
        }
        return [];
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<OfferEntity> createOffer(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ServerStrings.offers, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic resData = response.data['data'] ?? response.data;
        return OfferModel.fromJson(Map<String, dynamic>.from(resData as Map)).toDomain();
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<OfferEntity> updateOffer(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(ServerStrings.offerById(id), data: data);
      if (response.statusCode == 200) {
        final dynamic resData = response.data['data'] ?? response.data;
        return OfferModel.fromJson(Map<String, dynamic>.from(resData as Map)).toDomain();
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteOffer(int id) async {
    try {
      final response = await dio.delete(ServerStrings.offerById(id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<OfferEntity> toggleOfferActive(int id) async {
    try {
      final response = await dio.put(ServerStrings.toggleOfferActive(id));
      if (response.statusCode == 200) {
        final dynamic resData = response.data['data'] ?? response.data;
        return OfferModel.fromJson(Map<String, dynamic>.from(resData as Map)).toDomain();
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ─── 14. Contact & WhatsApp Settings ──────────────────────────────────────
  @override
  Future<AdminContactSettingsEntity> getContactSettings() async {
    try {
      final response = await dio.get(ServerStrings.publicSettings);
      if (response.statusCode == 200) {
        final dynamic resData = response.data['data'] ?? response.data;
        return AdminContactSettingsEntity.fromJson(Map<String, dynamic>.from(resData as Map));
      }
      return const AdminContactSettingsEntity(
        whatsappNumber: '+966500000000',
        whatsappDefaultMessage: 'مرحباً، أود الاستفسار عن ذبائح المملكة',
        whatsappEnabled: true,
        supportPhone: '920000000',
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (_) {
      return const AdminContactSettingsEntity(
        whatsappNumber: '+966500000000',
        whatsappDefaultMessage: 'مرحباً، أود الاستفسار عن ذبائح المملكة',
        whatsappEnabled: true,
        supportPhone: '920000000',
      );
    }
  }

  @override
  Future<AdminContactSettingsEntity> updateContactSettings({
    required String whatsappNumber,
    required String whatsappDefaultMessage,
    required bool whatsappEnabled,
    required String supportPhone,
  }) async {
    try {
      final response = await dio.put(
        ServerStrings.updateContactSettings,
        data: {
          'whatsapp_number': whatsappNumber,
          'whatsapp_default_message': whatsappDefaultMessage,
          'whatsapp_enabled': whatsappEnabled,
          'support_phone': supportPhone,
        },
      );
      if (response.statusCode == 200) {
        final dynamic resData = response.data['data'] ?? response.data;
        return AdminContactSettingsEntity.fromJson(Map<String, dynamic>.from(resData as Map));
      }
      throw ServerException(
        errorMessageModel: ErrorMessageModel.fromJson(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
