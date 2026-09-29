import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_products_cubit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminProductsCubit Unit Tests (CRUD, Search, Filter, Availability)', () {
    test('loadProducts emits [AdminProductsLoading, AdminProductsLoaded] on success', () async {
      final cubit = AdminProductsCubit(repository: repository);
      final states = <AdminProductsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadProducts();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminProductsLoading>());
      expect(states[1], isA<AdminProductsLoaded>());
      final loaded = states[1] as AdminProductsLoaded;
      expect(loaded.products.length, 2);
      expect(loaded.products.first.title, 'خروف نعيمي بلدي');
    });

    test('loadProducts emits [AdminProductsLoading, AdminProductsError] on failure', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'فشل في تحميل المنتجات';

      final cubit = AdminProductsCubit(repository: repository);
      final states = <AdminProductsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadProducts();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminProductsLoading>());
      expect(states[1], isA<AdminProductsError>());
      expect((states[1] as AdminProductsError).message, 'فشل في تحميل المنتجات');
    });

    test('search filters products list by query keyword', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      cubit.search('عارضي');
      await pumpEventQueue();

      final state = cubit.state as AdminProductsLoaded;
      expect(state.products.length, 1);
      expect(state.products.first.title, 'تيس بلدي عارضي');
      expect(state.searchQuery, 'عارضي');
    });

    test('setCategoryFilter filters products list by categoryId', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      cubit.setCategoryFilter(1);
      await pumpEventQueue();

      final state = cubit.state as AdminProductsLoaded;
      expect(state.products.length, 1);
      expect(state.products.first.categoryId, 1);
      expect(state.selectedCategoryId, 1);
    });

    test('createProduct appends new product to list and returns true', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      final payload = {
        'name': 'حاشي بلدي طازج',
        'selling_price': 850.0,
        'category_id': 1,
      };

      final success = await cubit.createProduct(payload);

      expect(success, isTrue);
      expect(repository.lastCreatedProductPayload?['name'], 'حاشي بلدي طازج');
      final state = cubit.state as AdminProductsLoaded;
      expect(state.products.any((p) => p.title == 'حاشي بلدي طازج'), isTrue);
    });

    test('createProduct returns false on backend failure', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      repository.shouldFail = true;
      final success = await cubit.createProduct({'name': 'منتج فاشل'});

      expect(success, isFalse);
    });

    test('updateProduct modifies existing product in state and returns true', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      final success = await cubit.updateProduct(101, {
        'name': 'خروف نعيمي بلدي (سوبر ديلوكس)',
        'selling_price': 1400.0,
      });

      expect(success, isTrue);
      expect(repository.lastUpdatedProductId, 101);
      final state = cubit.state as AdminProductsLoaded;
      expect(state.products.firstWhere((p) => p.id == 101).title, 'خروف نعيمي بلدي (سوبر ديلوكس)');
    });

    test('updateProduct returns false on failure', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      repository.shouldFail = true;
      final success = await cubit.updateProduct(101, {'name': 'تعديل فاشل'});

      expect(success, isFalse);
    });

    test('deleteProduct removes product from state and returns true', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      final success = await cubit.deleteProduct(101);

      expect(success, isTrue);
      expect(repository.lastDeletedProductId, 101);
      final state = cubit.state as AdminProductsLoaded;
      expect(state.products.any((p) => p.id == 101), isFalse);
    });

    test('deleteProduct returns false on failure', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      repository.shouldFail = true;
      final success = await cubit.deleteProduct(101);

      expect(success, isFalse);
    });

    test('toggleAvailability updates product isAvailable status and returns true', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      final success = await cubit.toggleAvailability(101, false);

      expect(success, isTrue);
      expect(repository.lastToggledProductId, 101);
      expect(repository.lastToggledProductAvailability, isFalse);
      final state = cubit.state as AdminProductsLoaded;
      expect(state.products.firstWhere((p) => p.id == 101).isAvailable, isFalse);
    });

    test('toggleAvailability returns false on failure', () async {
      final cubit = AdminProductsCubit(repository: repository);
      await cubit.loadProducts();

      repository.shouldFail = true;
      final success = await cubit.toggleAvailability(101, false);

      expect(success, isFalse);
    });
  });
}
