import 'package:dhabayih_lmamlaka/core/payment/moyasar_payment_gateway.dart';
import 'package:dhabayih_lmamlaka/core/payment/myfatoorah_payment_gateway.dart';
import 'package:dhabayih_lmamlaka/core/payment/payment_request.dart';
import 'package:dhabayih_lmamlaka/core/payment/payment_service.dart';
import 'package:dhabayih_lmamlaka/core/payment/payment_status.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/data/models/cart_model.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/data/models/order_model.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/entities/checkout_summary_entity.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/domain/entities/order_entity.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/presentation/views/native_payment_screen.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/presentation/views/widgets/delivery_calendar_widget.dart';
import 'package:dhabayih_lmamlaka/features/user/orders/presentation/views/widgets/invoice_preview_sheet.dart';
import 'package:dhabayih_lmamlaka/features/user/product/views/widgets/product_details_widgets.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapRtl(Widget child, {bool useScaffold = true}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: useScaffold
            ? Scaffold(body: SingleChildScrollView(child: child))
            : child,
      ),
    ),
  );
}

void main() {
  group('Requirement 2: Remove delivery fees from invoice', () {
    testWidgets('InvoicePreviewSheet displays order breakdown without any delivery fee line',
        (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(430, 1200);
      addTearDown(tester.view.reset);

      const order = OrderDetailEntity(
        id: 501,
        name: 'ORD-2026-0501',
        date: '2026-10-28 14:30:00',
        state: 'confirmed',
        paymentStatus: 'paid',
        paymentMethod: 'moyasar',
        subtotal: 1920.0,
        discountAmount: 0.0,
        pointsRedeemed: 1000,
        loyaltyDiscountAmount: 100.0,
        deliveryFee: 0.0,
        taxAmount: 273.0,
        total: 2093.0,
        slaughterDate: '2026-10-29',
        slaughterTime: 'صباحاً (8:00 ص - 12:00 م)',
        lines: [
          OrderLineEntity(
            id: 1,
            productId: 10,
            name: 'نعيمي كشميري',
            quantity: 1,
            priceUnit: 1920.0,
            discount: 0.0,
            priceSubtotal: 1920.0,
            discountAmount: 0.0,
            sizeId: 3,
            sizeName: 'كبيير (16 - 18 كجم)',
            sizePrice: 1850.0,
            cuttingOption: ProductOption(id: 1, name: 'تقطيع ثلاجة', extraPrice: 40.0),
            cuttingPrice: 40.0,
            packaging: ProductOption(id: 2, name: 'تغليف سحب هواء', extraPrice: 30.0),
            packagingOptions: [
              ProductOption(id: 2, name: 'تغليف سحب هواء', extraPrice: 30.0),
            ],
            packagingPrice: 30.0,
            excludedParts: [],
          ),
        ],
        timeline: [],
      );

      await tester.pumpWidget(
        _wrapRtl(
          const Scaffold(body: InvoicePreviewSheet(order: order)),
          useScaffold: false,
        ),
      );
      await tester.pumpAndSettle();

      // Verify invoice shows order number, slaughter schedule, options & prices, loyalty discount, and total
      expect(find.textContaining('ORD-2026-0501'), findsOneWidget);
      expect(find.textContaining('2026-10-29'), findsOneWidget);
      expect(find.textContaining('تقطيع ثلاجة (+40 ر.س)'), findsOneWidget);
      expect(find.textContaining('تغليف سحب هواء (+30 ر.س)'), findsOneWidget);
      expect(find.textContaining('خصم نقاط الولاء'), findsOneWidget);

      // Delivery fee line must never appear on the invoice
      expect(find.textContaining('رسوم التوصيل'), findsNothing);
      expect(find.textContaining('التوصيل المبرد'), findsNothing);
    });
  });

  group('Requirement 3: Product sizes synchronization & no fabricated defaults', () {
    test('Product with no sizes does not fabricate full/half/quarter portions', () {
      const productWithoutSizes = Product(
        id: 101,
        title: 'حاشي بلدي',
        subtitle: 'لحم طازج',
        imageUrl: 'assets/images/kingdom/camel.jpg',
        price: 2400,
        isCarcass: true,
        hasSizes: false,
        sizes: [],
      );

      expect(productWithoutSizes.effectivePortions, isEmpty);
    });

    test('Product with dashboard-assigned sizes only exposes assigned portions and prices', () {
      const productWithCustomSizes = Product(
        id: 102,
        title: 'خروف حري',
        subtitle: 'ذبيحة بلدي',
        imageUrl: 'assets/images/kingdom/sheep.jpg',
        price: 1600,
        isCarcass: true,
        hasSizes: true,
        sizes: [
          ProductSize(
            id: 11,
            name: 'وسط',
            portionType: 'full',
            weightRange: '12-14 كجم',
            price: 1650,
          ),
          ProductSize(
            id: 12,
            name: 'نصف ذبيحة',
            portionType: 'half',
            weightRange: '6-7 كجم',
            price: 850,
          ),
        ],
      );

      final portions = productWithCustomSizes.effectivePortions;
      expect(portions.length, 2);
      expect(portions.map((p) => p.type).toList(), ['full', 'half']);
      expect(portions.firstWhere((p) => p.type == 'full').startingPrice, 1650);
      expect(portions.firstWhere((p) => p.type == 'half').startingPrice, 850);
      // Quarter was not assigned in dashboard, so it must not be fabricated
      expect(portions.where((p) => p.type == 'quarter'), isEmpty);
    });
  });

  group('Requirement 5: Preparation (cutting) and packaging fees', () {
    test('CartLineModel and OrderLineModel parse cutting and packaging extra prices', () {
      final cartLine = CartLineModel.fromJson({
        'id': 7,
        'product_id': 10,
        'product_name': 'نعيمي بلدي',
        'size_id': 5,
        'size_name': 'وسط',
        'size_price': 1800.0,
        'cutting_option': {
          'id': 2,
          'name': 'تقطيع أرباع',
          'extra_price': 25.0,
        },
        'packaging_options': [
          {
            'id': 3,
            'name': 'أطباق مغلفة',
            'extra_price': 35.0,
          },
        ],
        'cutting_price': 25.0,
        'packaging_price': 35.0,
        'quantity': 2,
        'price_unit': 1860.0,
        'line_total': 3720.0,
      });

      expect(cartLine.sizeId, 5);
      expect(cartLine.sizeName, 'وسط');
      expect(cartLine.cuttingPrice, 25.0);
      expect(cartLine.packagingPrice, 35.0);
      expect(cartLine.priceUnit, 1860.0); // 1800 + 25 + 35
      expect(cartLine.lineTotal, 3720.0); // 1860 * 2 units

      final orderLine = OrderLineModel.fromJson({
        'id': 91,
        'product_id': 10,
        'name': 'نعيمي بلدي',
        'quantity': 2,
        'price_unit': 1860.0,
        'price_subtotal': 3720.0,
        'size_id': 5,
        'size_name': 'وسط',
        'size_price': 1800.0,
        'cutting_option': {
          'id': 2,
          'name': 'تقطيع أرباع',
          'extra_price': 25.0,
        },
        'cutting_price': 25.0,
        'packaging': {
          'id': 3,
          'name': 'أطباق مغلفة',
          'extra_price': 35.0,
        },
        'packaging_price': 35.0,
      });

      final orderLineEntity = orderLine.toDomain();
      expect(orderLineEntity.sizeId, 5);
      expect(orderLineEntity.sizeName, 'وسط');
      expect(orderLineEntity.sizePrice, 1800.0);
      expect(orderLineEntity.cuttingOption?.name, 'تقطيع أرباع');
      expect(orderLineEntity.cuttingPrice, 25.0);
      expect(orderLineEntity.packaging?.name, 'أطباق مغلفة');
      expect(orderLineEntity.packagingPrice, 35.0);
    });

    testWidgets('SelectionSummary renders size, cutting fee, packaging fee, and quantity breakdown',
        (tester) async {
      const cuttingOpt = ProductOption(id: 1, name: 'تقطيع ثلاجة', extraPrice: 30);
      const pkgOpt = ProductOption(id: 2, name: 'تغليف حراري', extraPrice: 45);
      const product = Product(
        id: 1,
        title: 'نعيمي كشميري',
        subtitle: 'ذبيحة طازجة',
        imageUrl: 'assets/images/kingdom/sheep.jpg',
        price: 1500,
        cuttingOptions: [cuttingOpt],
        packagingOptions: [pkgOpt],
      );
      const selectedSize = ProductSize(
        id: 10,
        name: 'كبيير',
        portionType: 'full',
        weightRange: '16-18 كجم',
        price: 1500,
      );

      await tester.pumpWidget(
        _wrapRtl(
          const SelectionSummary(
            product: product,
            selectedSize: selectedSize,
            selectedCuttingOption: cuttingOpt,
            selectedPackagingIds: {2},
            selectedExcludedPartIds: {},
            quantity: 2,
            unitBasePrice: 1500,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('كبيير', findRichText: true), findsOneWidget);
      expect(find.textContaining('تقطيع ثلاجة (+30 ر.س)', findRichText: true), findsOneWidget);
      expect(find.textContaining('تغليف حراري (+45 ر.س)', findRichText: true), findsOneWidget);
      // (1500 + 30 + 45) * 2 = 3150
      expect(find.textContaining('3150', findRichText: true), findsWidgets);
    });
  });

  group('Requirement 6: Loyalty point redemption at checkout', () {
    test('CheckoutSummaryEntity exposes backend loyalty balance, conversion rate, and min redemption', () {
      final summary = CheckoutSummaryEntity(
        cartSummary: const {'subtotal': 1000.0},
        deliveryMethods: const [],
        paymentMethods: const [],
        orderSummary: const {
          'subtotal': 1000.0,
          'discount_amount': 0.0,
          'delivery_fee': 0.0,
          'tax_amount': 150.0,
          'total': 1150.0,
        },
        loyalty: const {
          'available_points': 500,
          'redemption_rate': 10.0,
          'min_redemption': 100,
          'earning_rate': 1.0,
          'is_eligible': true,
          'max_discount_sar': 50.0,
        },
      );

      expect(summary.availablePoints, 500);
      expect(summary.redemptionRate, 10.0);
      expect(summary.minRedemption, 100);
      expect(summary.isLoyaltyEligible, isTrue);
      expect(summary.maxLoyaltyDiscountSar, 50.0); // 500 / 10 = 50 SAR
    });
  });

  group('Requirement 7: Slaughter date and time validation in Asia/Riyadh timezone', () {
    test('DeliveryCalendarWidget.isScheduleValid validates against Riyadh time (UTC+3)', () {
      // Simulate 2026-10-28 at 13:00 Riyadh time
      final riyadhMorningPassed = DateTime(2026, 10, 28, 13, 0);

      // Missing date or time is invalid
      expect(
        DeliveryCalendarWidget.isScheduleValid('', 'morning', nowOverride: riyadhMorningPassed),
        isFalse,
      );
      expect(
        DeliveryCalendarWidget.isScheduleValid('2026-10-28', '', nowOverride: riyadhMorningPassed),
        isFalse,
      );

      // Past date is invalid
      expect(
        DeliveryCalendarWidget.isScheduleValid('2026-10-27', 'evening', nowOverride: riyadhMorningPassed),
        isFalse,
      );

      // Today morning slot (ends at 12:00 Riyadh) is invalid at 13:00 Riyadh
      expect(
        DeliveryCalendarWidget.isScheduleValid('2026-10-28', 'morning', nowOverride: riyadhMorningPassed),
        isFalse,
      );

      // Today afternoon (ends 16:00) and evening (ends 20:00) are valid at 13:00 Riyadh
      expect(
        DeliveryCalendarWidget.isScheduleValid('2026-10-28', 'afternoon', nowOverride: riyadhMorningPassed),
        isTrue,
      );
      expect(
        DeliveryCalendarWidget.isScheduleValid('2026-10-28', 'evening', nowOverride: riyadhMorningPassed),
        isTrue,
      );

      // Tomorrow morning is valid
      expect(
        DeliveryCalendarWidget.isScheduleValid('2026-10-29', 'morning', nowOverride: riyadhMorningPassed),
        isTrue,
      );
    });
  });

  group('Requirements 8 & 9: MyFatoorah removal and Moyasar Condition Error fix', () {
    testWidgets('MyFatoorah is blocked and only Moyasar is active in PaymentService',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        _wrapRtl(
          Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final moyasarGateway = MoyasarPaymentGateway();
      final paymentService = PaymentService()
        ..registerGateway(moyasarGateway)
        ..registerGateway(MyFatoorahPaymentGateway());

      expect(paymentService.isGatewayRegistered('moyasar'), isTrue);
      expect(paymentService.isGatewayRegistered('myfatoorah'), isFalse);

      final mfResult = await paymentService.processPayment(
        capturedContext,
        'myfatoorah',
        const PaymentRequest(
          orderId: 10,
          orderNumber: 'ORD-10',
          amount: 500.0,
          currency: 'SAR',
          paymentMethodCode: 'myfatoorah',
        ),
      );
      expect(mfResult.status, AppPaymentStatus.failed);
      expect(mfResult.errorMessage, contains('ميسر'));

      final directMfResult = await MyFatoorahPaymentGateway().processPayment(
        capturedContext,
        const PaymentRequest(
          orderId: 10,
          orderNumber: 'ORD-10',
          amount: 500.0,
          currency: 'SAR',
          paymentMethodCode: 'myfatoorah',
        ),
      );
      expect(directMfResult.status, AppPaymentStatus.failed);
    });

    testWidgets('MoyasarPaymentGateway validates publishable key and amount to prevent Condition Error',
        (tester) async {
      expect(MoyasarPaymentGateway.isValidPublishableKey(null), isFalse);
      expect(MoyasarPaymentGateway.isValidPublishableKey(''), isFalse);
      expect(MoyasarPaymentGateway.isValidPublishableKey('dummy_public_key_placeholder'), isFalse);
      expect(MoyasarPaymentGateway.isValidPublishableKey('sk_test_secret'), isFalse);
      expect(MoyasarPaymentGateway.isValidPublishableKey('pk_test_valid1234567890'), isTrue);
      expect(MoyasarPaymentGateway.isValidPublishableKey('pk_live_valid1234567890'), isTrue);

      late BuildContext capturedContext;
      await tester.pumpWidget(
        _wrapRtl(
          Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final gateway = MoyasarPaymentGateway();

      // Missing/placeholder key returns graceful AppPaymentStatus.failed instead of AssertionError
      final badKeyResult = await gateway.processPayment(
        capturedContext,
        const PaymentRequest(
          orderId: 99,
          orderNumber: 'ORD-99',
          amount: 150.0,
          currency: 'SAR',
          paymentMethodCode: 'moyasar',
          publishableKey: 'dummy_public_key_placeholder',
        ),
      );
      expect(badKeyResult.status, AppPaymentStatus.failed);

      // Amount < 1 SAR (< 100 halalas) returns graceful AppPaymentStatus.failed instead of AssertionError
      final zeroAmountResult = await gateway.processPayment(
        capturedContext,
        const PaymentRequest(
          orderId: 99,
          orderNumber: 'ORD-99',
          amount: 0.0,
          currency: 'SAR',
          paymentMethodCode: 'moyasar',
          publishableKey: 'pk_test_valid1234567890',
        ),
      );
      expect(zeroAmountResult.status, AppPaymentStatus.failed);
    });

    testWidgets('NativePaymentScreen shows Arabic configuration warning instead of crashing with Condition Error when key is invalid',
        (tester) async {
      await tester.pumpWidget(
        _wrapRtl(
          const NativePaymentScreen(
            publishableKey: 'dummy_public_key_placeholder',
            amountMinorUnits: 185000,
            orderId: 501,
            orderNumber: 'ORD-501',
            totalAmount: 1850.0,
          ),
          useScaffold: false,
        ),
      );
      await tester.pump();

      // Must not throw AssertionError ("Condition Error") from moyasar PaymentConfig
      expect(tester.takeException(), isNull);
      expect(find.textContaining('مفتاح بوابة الدفع ميسر'), findsOneWidget);
    });
  });
}
