import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_dashboard_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/admin_stat_card.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminDashboardCubit Unit Tests (KPIs & Analytics)', () {
    test('loadStats emits [AdminDashboardLoading, AdminDashboardLoaded] on success', () async {
      final cubit = AdminDashboardCubit(repository: repository);
      final states = <AdminDashboardState>[];
      cubit.stream.listen(states.add);

      await cubit.loadStats();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminDashboardLoading>());
      expect(states[1], isA<AdminDashboardLoaded>());
      final loaded = states[1] as AdminDashboardLoaded;
      expect(loaded.stats.totalOrders, 150);
      expect(loaded.stats.todaySales, 15400.0);
      expect(loaded.stats.totalProducts, 48);
      expect(loaded.stats.lowStockCount, 3);
      expect(loaded.stats.totalCustomers, 95);
    });

    test('loadStats emits [AdminDashboardLoading, AdminDashboardError] on failure', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'خطأ في جلب إحصائيات الداشبورد';

      final cubit = AdminDashboardCubit(repository: repository);
      final states = <AdminDashboardState>[];
      cubit.stream.listen(states.add);

      await cubit.loadStats();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminDashboardLoading>());
      expect(states[1], isA<AdminDashboardError>());
      expect((states[1] as AdminDashboardError).message, 'خطأ في جلب إحصائيات الداشبورد');
    });
  });

  group('AdminStatCard Widget Tests', () {
    testWidgets('AdminStatCard renders title, value, icon, and gradient cleanly', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestAppWidget(
          child: AdminStatCard(
            title: 'إجمالي المبيعات',
            value: '15,400 ر.س',
            subtitle: '+18% مقارنة بالأمس',
            icon: Icons.trending_up,
            gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إجمالي المبيعات'), findsOneWidget);
      expect(find.text('15,400 ر.س'), findsOneWidget);
      expect(find.text('+18% مقارنة بالأمس'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);

      await tester.tap(find.text('إجمالي المبيعات'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
