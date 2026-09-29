import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/network/error_message_model.dart';
import 'package:dhabayih_lmamlaka/features/admin/domain/entities/admin_entities.dart';
import 'package:dhabayih_lmamlaka/features/admin/domain/repositories/admin_repository.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_categories_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_marketing_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_options_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_products_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_users_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/category.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/offers/domain/entities/offer_entity.dart';

Failure _mockFailure([String msg = 'Operation failed']) {
  return ServerFailure(ErrorMessageModel(
    message: msg,
    errors: const [],
    success: false,
    statusCode: 400,
  ));
}

/// Fake repository implementing [AdminRepository] to verify admin add operations.
class FakeAdminRepository implements AdminRepository {
  bool shouldFail = false;
  String failureMessage = 'Failed to perform operation';

  Map<String, dynamic>? lastCreatedCategoryPayload;
  Map<String, dynamic>? lastCreatedProductPayload;
  Map<String, dynamic>? lastCreatedBannerPayload;
  Map<String, dynamic>? lastCreatedCouponPayload;
  Map<String, dynamic>? lastCreatedUserPayload;
  Map<String, dynamic>? lastSavedOptionPayload;

  @override
  Future<Either<Failure, Category>> createCategory(Map<String, dynamic> data) async {
    lastCreatedCategoryPayload = data;
    if (shouldFail) {
      return Left(_mockFailure(failureMessage));
    }
    return Right(Category(
      id: 101,
      name: data['name'] ?? 'Test Category',
      imageUrl: data['image'] != null ? 'http://example.com/cat.png' : '',
    ));
  }

  @override
  Future<Either<Failure, List<Category>>> getAdminCategories() async {
    if (shouldFail) {
      return Left(_mockFailure(failureMessage));
    }
    return const Right([
      Category(id: 1, name: 'لحوم', imageUrl: 'http://example.com/meat.png'),
      Category(id: 101, name: 'مشروبات', imageUrl: 'http://example.com/drink.png'),
    ]);
  }

  @override
  Future<Either<Failure, Product>> createProduct(Map<String, dynamic> data) async {
    lastCreatedProductPayload = data;
    if (shouldFail) {
      return Left(_mockFailure(failureMessage));
    }
    return Right(Product(
      id: 201,
      title: data['name'] ?? 'Test Product',
      subtitle: '',
      price: (data['selling_price'] as num?)?.toDouble() ?? 100.0,
      imageUrl: 'http://example.com/prod.png',
      categoryId: data['category_id'] as int?,
      isAvailable: true,
      description: data['description'] ?? '',
    ));
  }

  @override
  Future<Either<Failure, List<Product>>> getAdminProducts({
    String? query,
    int? categoryId,
    String? filter,
    int limit = 20,
    int offset = 0,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, AdminBannerEntity>> createBanner(Map<String, dynamic> data) async {
    lastCreatedBannerPayload = data;
    if (shouldFail) {
      return Left(_mockFailure(failureMessage));
    }
    return Right(AdminBannerEntity(
      id: 301,
      title: data['title'] ?? 'Test Banner',
      imageUrl: 'http://example.com/banner.png',
      displayOrder: data['sequence'] ?? 1,
      isActive: data['is_active'] ?? true,
    ));
  }

  @override
  Future<Either<Failure, List<AdminBannerEntity>>> getAdminBanners() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, AdminCouponEntity>> createCoupon(Map<String, dynamic> data) async {
    lastCreatedCouponPayload = data;
    if (shouldFail) {
      return Left(_mockFailure(failureMessage));
    }
    return Right(AdminCouponEntity(
      id: 401,
      code: data['code'] ?? 'TEST10',
      discountType: data['discount_type'] ?? 'percentage',
      discountValue: (data['amount'] as num?)?.toDouble() ?? 10.0,
      minOrderValue: 0.0,
      expiryDate: '2026-12-31',
      isActive: true,
    ));
  }

  @override
  Future<Either<Failure, List<AdminCouponEntity>>> getAdminCoupons() async {
    return const Right([]);
  }

  Map<String, dynamic>? lastCreatedHighlightPayload;

  @override
  Future<Either<Failure, List<AdminHighlightEntity>>> getAdminHighlights() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, AdminHighlightEntity>> createAdminHighlight(Map<String, dynamic> data) async {
    lastCreatedHighlightPayload = data;
    if (shouldFail) {
      return Left(_mockFailure(failureMessage));
    }
    return Right(AdminHighlightEntity(
      id: 701,
      mediaUrl: 'http://example.com/story.jpg',
      mediaType: data['media_type'] ?? 'image',
      title: data['title'] ?? 'Story',
    ));
  }

  @override
  Future<Either<Failure, AdminUserEntity>> createAdminUser(Map<String, dynamic> data) async {
    lastCreatedUserPayload = data;
    if (shouldFail) {
      return Left(_mockFailure(failureMessage));
    }
    return Right(AdminUserEntity(
      id: 501,
      name: data['name'] ?? 'Test User',
      phone: data['phone'] ?? '0501234567',
      email: data['email'] ?? 'test@example.com',
      userType: data['user_type'] ?? 'customer',
      status: 'active',
    ));
  }

  @override
  Future<Either<Failure, List<AdminUserEntity>>> getAdminUsers({
    String? status,
    String? userType,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, AdminOptionEntity>> saveOption(Map<String, dynamic> data) async {
    lastSavedOptionPayload = data;
    if (shouldFail) {
      return Left(_mockFailure(failureMessage));
    }
    return Right(AdminOptionEntity(
      id: 601,
      name: data['name'] ?? 'Test Option',
      type: data['type'] ?? 'cutting',
      extraPrice: (data['extra_price'] as num?)?.toDouble() ?? 0.0,
      isActive: true,
    ));
  }

  @override
  Future<Either<Failure, List<AdminOptionEntity>>> getAdminOptions({String? type}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<AdminSizeEntity>>> getAdminSizes({int? productId}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, AdminSizeEntity>> saveSize(Map<String, dynamic> data) async {
    return Right(AdminSizeEntity.fromMap(data));
  }

  @override
  Future<Either<Failure, void>> deleteSize(int id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<OfferEntity>>> getAdminOffers({bool includeInactive = true}) async {
    return const Right([]);
  }

  // Stubs for remaining interface methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('Admin Add Category Tests', () {
    test('createCategory successfully creates category with name and image', () async {
      final cubit = AdminCategoriesCubit(repository: repository);
      final payload = {
        'name': 'مشروبات',
        'image': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      };

      final result = await cubit.createCategory(payload);

      expect(result, isTrue);
      expect(repository.lastCreatedCategoryPayload, equals(payload));
      expect(repository.lastCreatedCategoryPayload?['name'], equals('مشروبات'));
      expect(repository.lastCreatedCategoryPayload?['image'], isNotNull);
    });

    test('createCategory returns false when repository fails', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'فشل في حفظ القسم، يرجى المحاولة مرة أخرى';

      final cubit = AdminCategoriesCubit(repository: repository);
      final result = await cubit.createCategory({'name': 'قسم خاطئ'});

      expect(result, isFalse);
    });
  });

  group('Admin Add Product Tests', () {
    test('createProduct successfully creates product with required fields', () async {
      final cubit = AdminProductsCubit(repository: repository);
      final payload = {
        'name': 'ذبيحة نعيمي كشميري',
        'selling_price': 1200.0,
        'category_id': 1,
        'description': 'طازجة ومختارة بعناية',
      };

      final result = await cubit.createProduct(payload);

      expect(result, isTrue);
      expect(repository.lastCreatedProductPayload?['name'], equals('ذبيحة نعيمي كشميري'));
      expect(repository.lastCreatedProductPayload?['selling_price'], equals(1200.0));
      expect(repository.lastCreatedProductPayload?['category_id'], equals(1));
    });

    test('createProduct returns false on backend error', () async {
      repository.shouldFail = true;
      final cubit = AdminProductsCubit(repository: repository);

      final result = await cubit.createProduct({'name': 'منتج غير صالح'});

      expect(result, isFalse);
    });
  });

  group('Admin Add Banner Tests', () {
    test('createBanner successfully creates marketing banner', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      final payload = {
        'title': 'عرض اليوم الوطني',
        'sequence': 1,
        'is_active': true,
        'image': 'base64_banner_string',
      };

      final result = await cubit.createBanner(payload);

      expect(result, isTrue);
      expect(repository.lastCreatedBannerPayload?['title'], equals('عرض اليوم الوطني'));
      expect(repository.lastCreatedBannerPayload?['sequence'], equals(1));
      expect(repository.lastCreatedBannerPayload?['is_active'], isTrue);
    });

    test('createBanner returns false when marketing cubit encounters error', () async {
      repository.shouldFail = true;
      final cubit = AdminMarketingCubit(repository: repository);

      final result = await cubit.createBanner({'title': 'بانر فاشل'});

      expect(result, isFalse);
    });
  });

  group('Admin Add Coupon Tests', () {
    test('createCoupon successfully creates coupon code', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      final payload = {
        'code': 'DISCOUNT20',
        'amount': 20.0,
        'discount_type': 'percentage',
      };

      final result = await cubit.createCoupon(payload);

      expect(result, isTrue);
      expect(repository.lastCreatedCouponPayload?['code'], equals('DISCOUNT20'));
      expect(repository.lastCreatedCouponPayload?['amount'], equals(20.0));
      expect(repository.lastCreatedCouponPayload?['discount_type'], equals('percentage'));
    });

    test('createCoupon returns false on error', () async {
      repository.shouldFail = true;
      final cubit = AdminMarketingCubit(repository: repository);

      final result = await cubit.createCoupon({'code': 'INVALID'});

      expect(result, isFalse);
    });
  });

  group('Admin Add User CRM Tests', () {
    test('createCustomer successfully creates new customer/admin profile', () async {
      final cubit = AdminUsersCubit(repository);
      final payload = {
        'name': 'أحمد محمد',
        'phone': '0551234567',
        'email': 'ahmed@test.com',
        'user_type': 'customer',
      };

      final result = await cubit.createCustomer(payload);

      expect(result, isTrue);
      expect(repository.lastCreatedUserPayload?['name'], equals('أحمد محمد'));
      expect(repository.lastCreatedUserPayload?['phone'], equals('0551234567'));
      expect(repository.lastCreatedUserPayload?['email'], equals('ahmed@test.com'));
    });

    test('createCustomer returns false on validation failure', () async {
      repository.shouldFail = true;
      final cubit = AdminUsersCubit(repository);

      final result = await cubit.createCustomer({'name': 'مستخدم مكرر'});

      expect(result, isFalse);
    });
  });

  group('Admin Add Customization Options Tests', () {
    test('saveOption successfully adds cutting option', () async {
      final cubit = AdminOptionsCubit(repository: repository);
      final payload = {
        'name': 'تقطيع ثلاجة',
        'type': 'cutting',
        'extra_price': 0.0,
      };

      final result = await cubit.saveOption(payload);

      expect(result, isTrue);
      expect(repository.lastSavedOptionPayload?['name'], equals('تقطيع ثلاجة'));
      expect(repository.lastSavedOptionPayload?['type'], equals('cutting'));
    });

    test('saveOption successfully adds packaging option', () async {
      final cubit = AdminOptionsCubit(repository: repository);
      final payload = {
        'name': 'تغليف سحب هواء (فاكيوم)',
        'type': 'packaging',
        'extra_price': 25.0,
      };

      final result = await cubit.saveOption(payload);

      expect(result, isTrue);
      expect(repository.lastSavedOptionPayload?['name'], equals('تغليف سحب هواء (فاكيوم)'));
      expect(repository.lastSavedOptionPayload?['type'], equals('packaging'));
      expect(repository.lastSavedOptionPayload?['extra_price'], equals(25.0));
    });

    test('saveOption successfully adds excluded part option', () async {
      final cubit = AdminOptionsCubit(repository: repository);
      final payload = {
        'name': 'بدون كوارع',
        'type': 'excluded_part',
      };

      final result = await cubit.saveOption(payload);

      expect(result, isTrue);
      expect(repository.lastSavedOptionPayload?['name'], equals('بدون كوارع'));
      expect(repository.lastSavedOptionPayload?['type'], equals('excluded_part'));
    });

    test('saveOption returns false on failure', () async {
      repository.shouldFail = true;
      final cubit = AdminOptionsCubit(repository: repository);

      final result = await cubit.saveOption({'name': 'خيار فاشل'});

      expect(result, isFalse);
    });
  });

  group('Admin Add Highlight / Story Tests', () {
    test('createHighlight successfully uploads admin story', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      final payload = {
        'title': 'عرض اللحم الطازج',
        'media_type': 'image',
        'file': 'base64_story_data',
      };

      final result = await cubit.createHighlight(payload);

      expect(result, isTrue);
      expect(repository.lastCreatedHighlightPayload?['title'], equals('عرض اللحم الطازج'));
      expect(repository.lastCreatedHighlightPayload?['media_type'], equals('image'));
    });

    test('createHighlight returns false on failure', () async {
      repository.shouldFail = true;
      final cubit = AdminMarketingCubit(repository: repository);

      final result = await cubit.createHighlight({'title': 'ستوري فاشل'});

      expect(result, isFalse);
    });
  });
}
