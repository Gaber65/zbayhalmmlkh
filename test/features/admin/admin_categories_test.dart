import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_categories_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_options_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/category_form_dialog.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/option_form_dialog.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/category.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminCategoriesCubit Unit Tests (CRUD Actions)', () {
    test('loadCategories emits [AdminCategoriesLoading, AdminCategoriesLoaded] on success', () async {
      final cubit = AdminCategoriesCubit(repository: repository);
      final states = <AdminCategoriesState>[];
      cubit.stream.listen(states.add);

      await cubit.loadCategories();
      await pumpEventQueue();
      expect(states.length, 2);
      expect(states[0], isA<AdminCategoriesLoading>());
      expect(states[1], isA<AdminCategoriesLoaded>());
      final loaded = states[1] as AdminCategoriesLoaded;
      expect(loaded.categories.length, 2);
      expect(loaded.categories.first.name, 'ذبائح نعيمي');
    });

    test('loadCategories emits [AdminCategoriesLoading, AdminCategoriesError] on failure', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'خطأ في جلب الأقسام';

      final cubit = AdminCategoriesCubit(repository: repository);
      final states = <AdminCategoriesState>[];
      cubit.stream.listen(states.add);

      await cubit.loadCategories();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminCategoriesLoading>());
      expect(states[1], isA<AdminCategoriesError>());
      expect((states[1] as AdminCategoriesError).message, 'خطأ في جلب الأقسام');
    });

    test('createCategory adds category to loaded list and returns true', () async {
      final cubit = AdminCategoriesCubit(repository: repository);
      await cubit.loadCategories();

      final success = await cubit.createCategory({'name': 'قسم الحاشي'});

      expect(success, isTrue);
      expect(repository.lastCreatedCategoryPayload?['name'], 'قسم الحاشي');
      final state = cubit.state as AdminCategoriesLoaded;
      expect(state.categories.any((c) => c.name == 'قسم الحاشي'), isTrue);
    });

    test('createCategory returns false on repository failure', () async {
      final cubit = AdminCategoriesCubit(repository: repository);
      await cubit.loadCategories();

      repository.shouldFail = true;
      final success = await cubit.createCategory({'name': 'قسم فاشل'});

      expect(success, isFalse);
    });

    test('updateCategory modifies existing category in state and returns true', () async {
      final cubit = AdminCategoriesCubit(repository: repository);
      await cubit.loadCategories();

      final success = await cubit.updateCategory(1, {'name': 'ذبائح نعيمي ممتازة'});

      expect(success, isTrue);
      expect(repository.lastUpdatedCategoryId, 1);
      final state = cubit.state as AdminCategoriesLoaded;
      expect(state.categories.firstWhere((c) => c.id == 1).name, 'ذبائح نعيمي ممتازة');
    });

    test('updateCategory returns false on failure', () async {
      final cubit = AdminCategoriesCubit(repository: repository);
      await cubit.loadCategories();

      repository.shouldFail = true;
      final success = await cubit.updateCategory(1, {'name': 'تعديل فاشل'});

      expect(success, isFalse);
    });

    test('deleteCategory removes category from state and returns true', () async {
      final cubit = AdminCategoriesCubit(repository: repository);
      await cubit.loadCategories();

      final success = await cubit.deleteCategory(1);

      expect(success, isTrue);
      expect(repository.lastDeletedCategoryId, 1);
      final state = cubit.state as AdminCategoriesLoaded;
      expect(state.categories.any((c) => c.id == 1), isFalse);
    });

    test('deleteCategory returns false on repository failure', () async {
      final cubit = AdminCategoriesCubit(repository: repository);
      await cubit.loadCategories();

      repository.shouldFail = true;
      final success = await cubit.deleteCategory(1);

      expect(success, isFalse);
    });
  });

  group('AdminOptionsCubit Unit Tests (Options CRUD)', () {
    test('loadOptions emits [AdminOptionsLoading, AdminOptionsLoaded] with cuts and packagings', () async {
      final cubit = AdminOptionsCubit(repository: repository);
      final states = <AdminOptionsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadOptions();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminOptionsLoading>());
      expect(states[1], isA<AdminOptionsLoaded>());
      final loaded = states[1] as AdminOptionsLoaded;
      expect(loaded.options.length, 2);
    });

    test('saveOption adds or updates option and returns true', () async {
      final cubit = AdminOptionsCubit(repository: repository);
      await cubit.loadOptions();

      final success = await cubit.saveOption({
        'name': 'تقطيع مفاصل',
        'type': 'cutting',
        'extra_price': 10.0,
      });

      expect(success, isTrue);
      expect(repository.lastSavedOptionPayload?['name'], 'تقطيع مفاصل');
      final state = cubit.state as AdminOptionsLoaded;
      expect(state.options.any((o) => o.name == 'تقطيع مفاصل'), isTrue);
    });

    test('deleteOption removes option from state and returns true', () async {
      final cubit = AdminOptionsCubit(repository: repository);
      await cubit.loadOptions();

      final success = await cubit.deleteOption(201);

      expect(success, isTrue);
      expect(repository.lastDeletedOptionId, 201);
      final state = cubit.state as AdminOptionsLoaded;
      expect(state.options.any((o) => o.id == 201), isFalse);
    });
  });

  group('Category & Option Form Dialog Widget Tests', () {
    testWidgets('CategoryFormDialog validates required name and submits valid input', (tester) async {
      Map<String, dynamic>? submittedData;

      await tester.pumpWidget(
        createTestAppWidget(
          child: CategoryFormDialog(
            onSave: (data) async {
              submittedData = data;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify form dialog elements
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('إضافة قسم'), findsWidgets);

      // 1. Submit without entering name -> validation triggers
      await tester.tap(find.widgetWithText(ElevatedButton, 'إضافة قسم'));
      await tester.pumpAndSettle();
      expect(submittedData, isNull);

      // 2. Enter valid name and submit
      await tester.enterText(find.byType(TextFormField), 'قسم الحاشي والجمال');
      await tester.tap(find.widgetWithText(ElevatedButton, 'إضافة قسم'));
      await tester.pumpAndSettle();

      expect(submittedData, isNotNull);
      expect(submittedData?['name'], 'قسم الحاشي والجمال');
    });

    testWidgets('CategoryFormDialog populates existing category in edit mode', (tester) async {
      const editCategory = Category(id: 1, name: 'ذبائح نعيمي', imageUrl: '');

      await tester.pumpWidget(
        createTestAppWidget(
          child: CategoryFormDialog(
            category: editCategory,
            onSave: (data) async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ذبائح نعيمي'), findsOneWidget);
      expect(find.text('تعديل بيانات القسم'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'حفظ'), findsOneWidget);
    });

    testWidgets('OptionFormDialog validates and submits custom cut/packaging option', (tester) async {
      Map<String, dynamic>? submittedOption;

      await tester.pumpWidget(
        createTestAppWidget(
          child: OptionFormDialog(
            defaultType: 'cutting',
            onSave: (data) {
              submittedOption = data;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إضافة الخيار'), findsOneWidget);

      // Fill name (0) and extra price (1)
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'تقطيع أرباع');
      await tester.enterText(textFields.at(1), '20.0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'إضافة الخيار'));
      await tester.pumpAndSettle();

      expect(submittedOption, isNotNull);
      expect(submittedOption?['name'], 'تقطيع أرباع');
      expect(submittedOption?['extra_price'], 20.0);
      expect(submittedOption?['type'], 'cutting');
    });
  });
}
