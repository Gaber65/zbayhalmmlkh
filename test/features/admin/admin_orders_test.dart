import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_orders_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/admin_order_card.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/entities/order_entity.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminOrdersCubit Unit Tests (Load, Filter, Search, Status Update)', () {
    test('loadOrders emits [AdminOrdersLoading, AdminOrdersLoaded] on success', () async {
      final cubit = AdminOrdersCubit(repository: repository);
      final states = <AdminOrdersState>[];
      cubit.stream.listen(states.add);

      await cubit.loadOrders();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminOrdersLoading>());
      expect(states[1], isA<AdminOrdersLoaded>());
      final loaded = states[1] as AdminOrdersLoaded;
      expect(loaded.orders.length, 2);
      expect(loaded.orders.first.name, 'SO001');
    });

    test('loadOrders emits [AdminOrdersLoading, AdminOrdersError] on failure', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'تعذر الاتصال بسيرفر أودو';

      final cubit = AdminOrdersCubit(repository: repository);
      final states = <AdminOrdersState>[];
      cubit.stream.listen(states.add);

      await cubit.loadOrders();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminOrdersLoading>());
      expect(states[1], isA<AdminOrdersError>());
      expect((states[1] as AdminOrdersError).message, 'تعذر الاتصال بسيرفر أودو');
    });

    test('setFilter reloads orders with target state filter', () async {
      final cubit = AdminOrdersCubit(repository: repository);

      await cubit.setFilter('confirmed');
      await pumpEventQueue();

      final state = cubit.state as AdminOrdersLoaded;
      expect(state.orders.length, 1);
      expect(state.orders.first.name, 'SO002');
      expect(state.orders.first.state, 'confirmed');
      expect(state.activeFilter, 'confirmed');
    });

    test('search reloads orders matching query', () async {
      final cubit = AdminOrdersCubit(repository: repository);

      await cubit.search('محمد');
      await pumpEventQueue();

      final state = cubit.state as AdminOrdersLoaded;
      expect(state.orders.length, 1);
      expect(state.orders.first.customerName, 'محمد أحمد');
      expect(state.searchQuery, 'محمد');
    });

    test('updateOrderStatus updates state and calls repository', () async {
      final cubit = AdminOrdersCubit(repository: repository);
      await cubit.loadOrders();

      await cubit.updateOrderStatus(601, 'confirmed');

      expect(repository.lastUpdatedOrderStatusId, 601);
      expect(repository.lastUpdatedOrderNewStatus, 'confirmed');
    });
  });

  group('AdminOrderCard Widget Tests (Smart Status Progression & Tap)', () {
    testWidgets('AdminOrderCard renders customer info, total, and confirms pending order on tap', (tester) async {
      String? updatedStatus;
      bool cardTapped = false;

      const testOrder = OrderListItemEntity(
        id: 601,
        name: 'SO001',
        date: '2026-09-26 12:00:00',
        total: 1350.0,
        subtotal: 1350.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        itemCount: 1,
        state: 'pending',
        paymentStatus: 'pending',
        customerName: 'محمد أحمد',
        customerPhone: '0501112233',
      );

      await tester.pumpWidget(
        createTestAppWidget(
          child: AdminOrderCard(
            order: testOrder,
            onTap: () {
              cardTapped = true;
            },
            onStatusChange: (status) {
              updatedStatus = status;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify basic info displayed
      expect(find.text('SO001'), findsOneWidget);
      expect(find.text('محمد أحمد'), findsOneWidget);
      expect(find.text('1350.00 ر.س'), findsOneWidget);

      // Verify smart action button for pending state is "تأكيد الطلب"
      expect(find.text('تأكيد الطلب'), findsOneWidget);

      // Tap action button to advance status
      await tester.tap(find.text('تأكيد الطلب'));
      await tester.pumpAndSettle();

      expect(updatedStatus, 'confirmed');

      // Tap the card itself
      await tester.tap(find.text('SO001'));
      await tester.pumpAndSettle();
      expect(cardTapped, isTrue);
    });

    testWidgets('AdminOrderCard shows Start Preparing button for confirmed order', (tester) async {
      String? updatedStatus;

      const confirmedOrder = OrderListItemEntity(
        id: 602,
        name: 'SO002',
        date: '2026-09-26 13:00:00',
        total: 2200.0,
        subtotal: 2200.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        itemCount: 2,
        state: 'confirmed',
        paymentStatus: 'paid',
        customerName: 'فهد العتيبي',
      );

      await tester.pumpWidget(
        createTestAppWidget(
          child: AdminOrderCard(
            order: confirmedOrder,
            onTap: () {},
            onStatusChange: (status) {
              updatedStatus = status;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('بدء التجهيز والذبح'), findsOneWidget);

      await tester.tap(find.text('بدء التجهيز والذبح'));
      await tester.pumpAndSettle();

      expect(updatedStatus, 'preparing');
    });

    testWidgets('AdminOrderCard shows Mark Delivered button for out_delivery order', (tester) async {
      String? updatedStatus;

      const outOrder = OrderListItemEntity(
        id: 603,
        name: 'SO003',
        date: '2026-09-26 14:00:00',
        total: 950.0,
        subtotal: 950.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        itemCount: 1,
        state: 'out_delivery',
        paymentStatus: 'paid',
      );

      await tester.pumpWidget(
        createTestAppWidget(
          child: AdminOrderCard(
            order: outOrder,
            onTap: () {},
            onStatusChange: (status) {
              updatedStatus = status;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تأكيد التسليم بنجاح'), findsOneWidget);

      await tester.tap(find.text('تأكيد التسليم بنجاح'));
      await tester.pumpAndSettle();

      expect(updatedStatus, 'delivered');
    });
  });
}
