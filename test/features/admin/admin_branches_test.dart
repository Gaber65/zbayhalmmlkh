import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_branches_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/branch_form_dialog.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/views/admin_branches_view.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/entities/branch_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminBranchesCubit Unit Tests', () {
    test('loadBranches emits [AdminBranchesLoading, AdminBranchesLoaded] on success', () async {
      final cubit = AdminBranchesCubit(repository);
      final states = <AdminBranchesState>[];
      cubit.stream.listen(states.add);

      await cubit.loadBranches();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminBranchesLoading>());
      expect(states[1], isA<AdminBranchesLoaded>());
      final loaded = states[1] as AdminBranchesLoaded;
      expect(loaded.branches.length, 2);
      expect(loaded.branches.first.name, 'فرع الرياض الرئيسي');
      expect(loaded.branches.first.city, 'الرياض');
      expect(loaded.branches.first.isActive, isTrue);
    });

    test('loadBranches emits [AdminBranchesLoading, AdminBranchesError] on failure', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'فشل في تحميل الفروع من أودو';

      final cubit = AdminBranchesCubit(repository);
      final states = <AdminBranchesState>[];
      cubit.stream.listen(states.add);

      await cubit.loadBranches();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminBranchesLoading>());
      expect(states[1], isA<AdminBranchesError>());
      expect((states[1] as AdminBranchesError).message, 'فشل في تحميل الفروع من أودو');
    });

    test('createBranch adds branch to state and returns true', () async {
      final cubit = AdminBranchesCubit(repository);
      await cubit.loadBranches();

      final payload = {
        'name_ar': 'فرع الدمام الجديد',
        'city': 'الدمام',
        'address': 'طريق الملك فهد',
        'phone': '0509998877',
        'is_active': true,
      };

      final success = await cubit.createBranch(payload);

      expect(success, isTrue);
      expect(repository.lastCreatedBranchPayload?['name_ar'], 'فرع الدمام الجديد');
      final state = cubit.state as AdminBranchesLoaded;
      expect(state.branches.any((b) => b.name == 'فرع الدمام الجديد'), isTrue);
    });

    test('updateBranch modifies existing branch in state', () async {
      final cubit = AdminBranchesCubit(repository);
      await cubit.loadBranches();

      final payload = {
        'name_ar': 'فرع الرياض - النخيل المطور',
        'city': 'الرياض',
        'phone': '0501112233',
        'is_active': true,
      };

      final success = await cubit.updateBranch(1, payload);

      expect(success, isTrue);
      expect(repository.lastUpdatedBranchId, 1);
      final state = cubit.state as AdminBranchesLoaded;
      final updated = state.branches.firstWhere((b) => b.id == 1);
      expect(updated.name, 'فرع الرياض - النخيل المطور');
    });

    test('deleteBranch removes branch from state', () async {
      final cubit = AdminBranchesCubit(repository);
      await cubit.loadBranches();

      final success = await cubit.deleteBranch(1);

      expect(success, isTrue);
      expect(repository.lastDeletedBranchId, 1);
      final state = cubit.state as AdminBranchesLoaded;
      expect(state.branches.any((b) => b.id == 1), isFalse);
    });
  });

  group('Branch Dialog and View Widget Tests', () {
    testWidgets('BranchFormDialog validates required inputs and saves', (tester) async {
      Map<String, dynamic>? savedPayload;

      await tester.pumpWidget(
        createTestAppWidget(
          child: BranchFormDialog(
            onSave: (payload) async {
              savedPayload = payload;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إضافة فرع جديد'), findsWidgets);

      // Attempt to submit empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'إضافة الفرع'));
      await tester.pumpAndSettle();
      expect(savedPayload, isNull);

      // Fill in required fields
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'فرع الخبر');
      await tester.enterText(textFields.at(1), 'الخبر');
      await tester.enterText(textFields.at(3), 'شارع الظهران');
      await tester.enterText(textFields.at(4), '0555123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'إضافة الفرع'));
      await tester.pumpAndSettle();

      expect(savedPayload, isNotNull);
      expect(savedPayload?['name_ar'], 'فرع الخبر');
      expect(savedPayload?['city'], 'الخبر');
      expect(savedPayload?['phone'], '0555123456');
    });

    testWidgets('BranchFormDialog pre-populates existing branch data for editing', (tester) async {
      const existingBranch = BranchEntity(
        id: 10,
        name: 'فرع مكة المكرمة',
        address: 'حي العزيزية',
        phone: '0512345678',
        city: 'مكة المكرمة',
        isActive: true,
      );

      await tester.pumpWidget(
        createTestAppWidget(
          child: BranchFormDialog(
            branch: existingBranch,
            onSave: (payload) async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تعديل الفرع'), findsWidgets);
      expect(find.text('فرع مكة المكرمة'), findsOneWidget);
      expect(find.text('حي العزيزية'), findsOneWidget);
      expect(find.text('0512345678'), findsOneWidget);
    });

    testWidgets('AdminBranchesView renders branch list and search filter', (tester) async {
      final cubit = AdminBranchesCubit(repository);

      await tester.pumpWidget(
        createTestAppWidget(
          child: BlocProvider<AdminBranchesCubit>.value(
            value: cubit,
            child: const AdminBranchesView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إدارة الفروع ونقاط الاستلام'), findsWidgets);
      expect(find.text('فرع الرياض الرئيسي'), findsOneWidget);
      expect(find.text('فرع جدة'), findsOneWidget);

      // Filter by search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField.first, 'جدة');
      await tester.pumpAndSettle();

      expect(find.text('فرع جدة'), findsOneWidget);
      expect(find.text('فرع الرياض الرئيسي'), findsNothing);
    });
  });
}
