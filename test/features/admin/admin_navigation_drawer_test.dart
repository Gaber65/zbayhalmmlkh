import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhabayih_lmamlaka/core/app_cubit/app_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/widgets/admin_drawer.dart';
import '../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late AppCubit appCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    appCubit = AppCubit(prefs);
  });

  tearDown(() {
    appCubit.close();
  });

  group('AppCubit Preferences Unit Tests (Language & Theme)', () {
    test('initial state has Arabic locale and light/system theme', () {
      expect(appCubit.state.locale.languageCode, 'ar');
    });

    test('changeLanguage switches locale between ar and en', () async {
      await appCubit.changeLanguage('en');
      expect(appCubit.state.locale.languageCode, 'en');

      await appCubit.changeLanguage('ar');
      expect(appCubit.state.locale.languageCode, 'ar');
    });

    test('changeTheme switches ThemeMode between dark and light', () async {
      await appCubit.changeTheme(ThemeMode.dark);
      expect(appCubit.state.themeMode, ThemeMode.dark);

      await appCubit.changeTheme(ThemeMode.light);
      expect(appCubit.state.themeMode, ThemeMode.light);
    });

    test('toggleTheme alternates between light and dark', () async {
      await appCubit.changeTheme(ThemeMode.light);
      await appCubit.toggleTheme();
      expect(appCubit.state.themeMode, ThemeMode.dark);

      await appCubit.toggleTheme();
      expect(appCubit.state.themeMode, ThemeMode.light);
    });
  });

  group('AdminDrawer Widget Tests (Navigation & Preferences Actions)', () {
    testWidgets('AdminDrawer renders all 8 menu navigation items and triggers selection', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      int selectedIndex = 0;

      await tester.pumpWidget(
        createTestAppWidget(
          child: BlocProvider<AppCubit>.value(
            value: appCubit,
            child: AdminDrawer(
              selectedIndex: 0,
              onSelectIndex: (idx) {
                selectedIndex = idx;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header branding
      expect(find.text('ذبائح المملكة'), findsOneWidget);

      // Verify menu items (exact AdminI18n titles)
      expect(find.text('لوحة المعلومات والإحصائيات'), findsOneWidget);
      expect(find.text('إدارة الطلبات ودورة العمل'), findsOneWidget);
      expect(find.text('إدارة المنتجات والمخزون'), findsOneWidget);
      expect(find.text('الأقسام وخيارات التخصيص'), findsOneWidget);
      expect(find.text('إدارة العملاء (CRM)'), findsOneWidget);
      expect(find.text('المدفوعات والمعاملات'), findsOneWidget);
      expect(find.text('التسويق والحملات الترويجية'), findsOneWidget);
      expect(find.text('الإعدادات وبرنامج الولاء'), findsOneWidget);

      // Tap on Orders menu item (index 1) -> triggers selection and closes drawer via Navigator.pop
      await tester.tap(find.text('إدارة الطلبات ودورة العمل'));
      await tester.pumpAndSettle();
      expect(selectedIndex, 1);
    });

    testWidgets('AdminDrawer triggers language and theme switches', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestAppWidget(
          child: BlocProvider<AppCubit>.value(
            value: appCubit,
            child: AdminDrawer(
              selectedIndex: 0,
              onSelectIndex: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Preferences section
      expect(find.text('تفضيلات التطبيق'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('داكن'), findsOneWidget);

      // Tap English segment
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(appCubit.state.locale.languageCode, 'en');

      // Tap Dark theme segment
      await tester.tap(find.text('داكن'));
      await tester.pumpAndSettle();
      expect(appCubit.state.themeMode, ThemeMode.dark);

      // Verify Back to Storefront button exists
      expect(find.text('العودة لمتجر العملاء'), findsOneWidget);
    });
  });
}
