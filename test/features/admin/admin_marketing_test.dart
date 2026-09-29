import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_marketing_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/coupon_form_dialog.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/broadcast_notification_dialog.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeAdminRepository repository;

  setUp(() {
    repository = FakeAdminRepository();
  });

  group('AdminMarketingCubit Unit Tests (Coupons, Banners, Highlights, Push)', () {
    test('loadMarketingData emits [AdminMarketingLoading, AdminMarketingLoaded] on success', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      final states = <AdminMarketingState>[];
      cubit.stream.listen(states.add);

      await cubit.loadMarketingData();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminMarketingLoading>());
      expect(states[1], isA<AdminMarketingLoaded>());
      final loaded = states[1] as AdminMarketingLoaded;
      expect(loaded.coupons.length, 1);
      expect(loaded.banners.length, 1);
      expect(loaded.highlights.length, 1);
      expect(loaded.coupons.first.code, 'EID20');
    });

    test('loadMarketingData emits [AdminMarketingLoading, AdminMarketingLoaded] with empty lists on repository failure', () async {
      repository.shouldFail = true;

      final cubit = AdminMarketingCubit(repository: repository);
      final states = <AdminMarketingState>[];
      cubit.stream.listen(states.add);

      await cubit.loadMarketingData();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminMarketingLoading>());
      expect(states[1], isA<AdminMarketingLoaded>());
      final loaded = states[1] as AdminMarketingLoaded;
      expect(loaded.banners, isEmpty);
      expect(loaded.coupons, isEmpty);
      expect(loaded.highlights, isEmpty);
    });

    test('createCoupon adds coupon to state and returns true', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      await cubit.loadMarketingData();

      final payload = {
        'code': 'SUMMER50',
        'discount_type': 'percentage',
        'discount_value': 50.0,
        'min_order_value': 300.0,
      };

      final success = await cubit.createCoupon(payload);

      expect(success, isTrue);
      expect(repository.lastCreatedCouponPayload?['code'], 'SUMMER50');
      final state = cubit.state as AdminMarketingLoaded;
      expect(state.coupons.any((c) => c.code == 'SUMMER50'), isTrue);
    });

    test('toggleCoupon updates coupon status in state', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      await cubit.loadMarketingData();

      await cubit.toggleCoupon(401, false);

      expect(repository.lastToggledCouponId, 401);
      expect(repository.lastToggledCouponActive, isFalse);
      final state = cubit.state as AdminMarketingLoaded;
      expect(state.coupons.firstWhere((c) => c.id == 401).isActive, isFalse);
    });

    test('deleteCoupon removes coupon from state', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      await cubit.loadMarketingData();

      await cubit.deleteCoupon(401);

      expect(repository.lastDeletedCouponId, 401);
      final state = cubit.state as AdminMarketingLoaded;
      expect(state.coupons.any((c) => c.id == 401), isFalse);
    });

    test('createBanner appends banner to state and returns true', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      await cubit.loadMarketingData();

      final payload = {'title': 'بانر عروض نهاية الأسبوع', 'sequence': 2};
      final success = await cubit.createBanner(payload);

      expect(success, isTrue);
      expect(repository.lastCreatedBannerPayload?['title'], 'بانر عروض نهاية الأسبوع');
      final state = cubit.state as AdminMarketingLoaded;
      expect(state.banners.any((b) => b.title == 'بانر عروض نهاية الأسبوع'), isTrue);
    });

    test('updateBanner modifies banner and returns true', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      await cubit.loadMarketingData();

      final payload = {'title': 'بانر محدث'};
      final success = await cubit.updateBanner(301, payload);

      expect(success, isTrue);
      expect(repository.lastUpdatedBannerPayload?['title'], 'بانر محدث');
      final state = cubit.state as AdminMarketingLoaded;
      expect(state.banners.firstWhere((b) => b.id == 301).title, 'بانر محدث');
    });

    test('deleteBanner removes banner from state', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      await cubit.loadMarketingData();

      final success = await cubit.deleteBanner(301);

      expect(success, isTrue);
      expect(repository.lastDeletedBannerId, 301);
      final state = cubit.state as AdminMarketingLoaded;
      expect(state.banners.any((b) => b.id == 301), isFalse);
    });

    test('createHighlight and deleteHighlight update highlight list', () async {
      final cubit = AdminMarketingCubit(repository: repository);
      await cubit.loadMarketingData();

      final payload = {'title': 'ستوري ذبائح طازجة'};
      final addSuccess = await cubit.createHighlight(payload);
      expect(addSuccess, isTrue);
      expect(repository.lastCreatedHighlightPayload?['title'], 'ستوري ذبائح طازجة');

      final delSuccess = await cubit.deleteHighlight(501);
      expect(delSuccess, isTrue);
      expect(repository.lastDeletedHighlightId, 501);
    });

    test('sendBroadcastNotification invokes repository broadcast API', () async {
      final cubit = AdminMarketingCubit(repository: repository);

      final success = await cubit.sendBroadcastNotification(
        title: 'عرض محدود اليوم',
        body: 'احصل على خصم 15% على جميع الذبائح',
      );

      expect(success, isTrue);
      expect(repository.lastBroadcastTitle, 'عرض محدود اليوم');
      expect(repository.lastBroadcastBody, 'احصل على خصم 15% على جميع الذبائح');
    });
  });

  group('Marketing Dialogs Widget Tests', () {
    testWidgets('CouponFormDialog validates inputs and invokes onSave callback', (tester) async {
      Map<String, dynamic>? savedData;

      await tester.pumpWidget(
        createTestAppWidget(
          child: CouponFormDialog(
            onSave: (data) {
              savedData = data;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إضافة كود خصم'), findsWidgets);

      // Validate required fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'إضافة كود خصم'));
      await tester.pumpAndSettle();
      expect(savedData, isNull);

      // Enter valid code and discount value
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'DISCOUNT25');
      await tester.enterText(textFields.at(1), '25');

      await tester.tap(find.widgetWithText(ElevatedButton, 'إضافة كود خصم'));
      await tester.pumpAndSettle();

      expect(savedData, isNotNull);
      expect(savedData?['code'], 'DISCOUNT25');
      expect(savedData?['discount_value'], 25.0);
    });

    testWidgets('BroadcastNotificationDialog validates fields and triggers onSend', (tester) async {
      String? sentTitle;
      String? sentBody;

      await tester.pumpWidget(
        createTestAppWidget(
          child: BroadcastNotificationDialog(
            onSend: (title, body, topic) async {
              sentTitle = title;
              sentBody = body;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إرسال الإشعار الآن'), findsOneWidget);

      // Submit empty form -> validation fails
      await tester.tap(find.text('إرسال الإشعار الآن'));
      await tester.pumpAndSettle();
      expect(sentTitle, isNull);

      // Enter title and body
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'عروض نهاية الأسبوع');
      await tester.enterText(textFields.at(1), 'خصم 20% على التيوس والنعيمي');

      await tester.tap(find.text('إرسال الإشعار الآن'));
      await tester.pumpAndSettle();

      expect(sentTitle, 'عروض نهاية الأسبوع');
      expect(sentBody, 'خصم 20% على التيوس والنعيمي');
    });
  });
}
