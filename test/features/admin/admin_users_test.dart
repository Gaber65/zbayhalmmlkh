import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_users_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/customer_form_dialog.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminUsersCubit Unit Tests (CRM, Loyalty Points, CRUD)', () {
    test('loadUsers emits [AdminUsersLoading, AdminUsersLoaded] on success', () async {
      final cubit = AdminUsersCubit(repository);
      final states = <AdminUsersState>[];
      cubit.stream.listen(states.add);

      await cubit.loadUsers();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminUsersLoading>());
      expect(states[1], isA<AdminUsersLoaded>());
      final loaded = states[1] as AdminUsersLoaded;
      expect(loaded.users.length, 1);
      expect(loaded.users.first.name, 'سالم الشمري');
    });

    test('loadUsers emits [AdminUsersLoading, AdminUsersError] on failure', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'خطأ في جلب بيانات العملاء';

      final cubit = AdminUsersCubit(repository);
      final states = <AdminUsersState>[];
      cubit.stream.listen(states.add);

      await cubit.loadUsers();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminUsersLoading>());
      expect(states[1], isA<AdminUsersError>());
      expect((states[1] as AdminUsersError).message, 'خطأ في جلب بيانات العملاء');
    });

    test('loadUsers with query filters customer list by query', () async {
      final cubit = AdminUsersCubit(repository);

      await cubit.loadUsers(query: 'سالم');

      final state = cubit.state as AdminUsersLoaded;
      expect(state.users.length, 1);
      expect(state.users.first.name, 'سالم الشمري');
      expect(state.searchQuery, 'سالم');
    });

    test('createCustomer adds new customer to state and returns true', () async {
      final cubit = AdminUsersCubit(repository);
      await cubit.loadUsers();

      final payload = {
        'name': 'عبدالله المطيري',
        'phone': '0555554433',
        'email': 'abdullah@example.com',
        'user_type': 'individual',
      };

      final success = await cubit.createCustomer(payload);

      expect(success, isTrue);
      expect(repository.lastCreatedUserPayload?['name'], 'عبدالله المطيري');
      final state = cubit.state as AdminUsersLoaded;
      expect(state.users.any((u) => u.name == 'عبدالله المطيري'), isTrue);
    });

    test('updateCustomer modifies existing customer and returns true', () async {
      final cubit = AdminUsersCubit(repository);
      await cubit.loadUsers();

      final payload = {'name': 'سالم بن ناصر الشمري'};
      final success = await cubit.updateCustomer(701, payload);

      expect(success, isTrue);
      expect(repository.lastUpdatedUserPayload?['name'], 'سالم بن ناصر الشمري');
      final state = cubit.state as AdminUsersLoaded;
      expect(state.users.firstWhere((u) => u.id == 701).name, 'سالم بن ناصر الشمري');
    });

    test('toggleCustomerStatus updates customer active/suspended status', () async {
      final cubit = AdminUsersCubit(repository);
      await cubit.loadUsers();

      final success = await cubit.toggleCustomerStatus(701, false);

      expect(success, isTrue);
      expect(repository.lastUpdatedUserNewStatus, 'suspended');
      expect(repository.lastUpdatedUserStatusId, 701);
      final state = cubit.state as AdminUsersLoaded;
      expect(state.users.firstWhere((u) => u.id == 701).status, 'suspended');
    });

    test('deleteCustomer removes customer from state and returns true', () async {
      final cubit = AdminUsersCubit(repository);
      await cubit.loadUsers();

      final success = await cubit.deleteCustomer(701);

      expect(success, isTrue);
      expect(repository.lastDeletedUserId, 701);
      final state = cubit.state as AdminUsersLoaded;
      expect(state.users.any((u) => u.id == 701), isFalse);
    });

    test('adjustLoyaltyPoints updates customer balance and returns true', () async {
      final cubit = AdminUsersCubit(repository);
      await cubit.loadUsers();

      final success = await cubit.adjustLoyaltyPoints(
        userId: 701,
        pointsChange: 100,
        reason: 'مكافأة ولاء إضافية',
      );

      expect(success, isTrue);
      expect(repository.lastAdjustedLoyaltyUserId, 701);
      expect(repository.lastAdjustedLoyaltyPoints, 100);
      expect(repository.lastAdjustedLoyaltyReason, 'مكافأة ولاء إضافية');
      final state = cubit.state as AdminUsersLoaded;
      expect(state.users.firstWhere((u) => u.id == 701).loyaltyPoints, 450);
    });
  });

  group('CustomerFormDialog Widget Tests (Action Coverage)', () {
    testWidgets('CustomerFormDialog validates inputs and submits correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Map<String, dynamic>? createdData;

      await tester.pumpWidget(
        createTestAppWidget(
          child: CustomerFormDialog(
            onSave: (data) async {
              createdData = data;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إنشاء العميل'), findsOneWidget);

      // Submit without entering data -> validation prevents submission
      await tester.tap(find.text('إنشاء العميل'));
      await tester.pumpAndSettle();
      expect(createdData, isNull);

      // Enter valid fields
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'خالد العسيري');
      await tester.enterText(textFields.at(1), '0551122334');
      await tester.enterText(textFields.at(2), 'khaled@example.com');

      await tester.tap(find.text('إنشاء العميل'));
      await tester.pumpAndSettle();

      expect(createdData, isNotNull);
      expect(createdData?['name'], 'خالد العسيري');
      expect(createdData?['phone'], '0551122334');
      expect(createdData?['email'], 'khaled@example.com');
    });
  });
}
