import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_payments_cubit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminPaymentsCubit Unit Tests (Payments & Loyalty Logs)', () {
    test('loadPaymentsData emits [AdminPaymentsLoading, AdminPaymentsLoaded] on success', () async {
      final cubit = AdminPaymentsCubit(repository);
      final states = <AdminPaymentsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadPaymentsData();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminPaymentsLoading>());
      expect(states[1], isA<AdminPaymentsLoaded>());
      final loaded = states[1] as AdminPaymentsLoaded;
      expect(loaded.paymentTransactions.length, 1);
      expect(loaded.paymentTransactions.first.paymentMethod, 'mada');
      expect(loaded.paymentTransactions.first.amount, 1350.0);
    });

    test('loadPaymentsData emits [AdminPaymentsLoading, AdminPaymentsError] on failure', () async {
      repository.shouldFail = true;
      repository.failureMessage = 'فشل في جلب سجل المدفوعات';

      final cubit = AdminPaymentsCubit(repository);
      final states = <AdminPaymentsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadPaymentsData();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminPaymentsLoading>());
      expect(states[1], isA<AdminPaymentsError>());
      expect((states[1] as AdminPaymentsError).message, 'فشل في جلب سجل المدفوعات');
    });

    test('filterStatus and search update state filters', () async {
      final cubit = AdminPaymentsCubit(repository);
      await cubit.loadPaymentsData();

      cubit.search('SO001');
      cubit.filterStatus('done');

      final state = cubit.state as AdminPaymentsLoaded;
      expect(state.searchQuery, 'SO001');
      expect(state.statusFilter, 'done');
    });

    test('filterMethod updates methodFilter in state', () async {
      final cubit = AdminPaymentsCubit(repository);
      await cubit.loadPaymentsData();

      cubit.filterMethod('mada');

      final state = cubit.state as AdminPaymentsLoaded;
      expect(state.methodFilter, 'mada');
    });
  });
}
