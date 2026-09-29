import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/web/web_why_choose_us_widget.dart';

void main() {
  testWidgets('WebWhyChooseUsWidget renders features cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: const Scaffold(
          body: SingleChildScrollView(
            child: WebWhyChooseUsWidget(),
          ),
        ),
      ),
    );

    expect(find.text('Why Choose Dhabayih Lmamlaka?'), findsOneWidget);
    expect(find.text('Verified Fresh Quality'), findsOneWidget);
    expect(find.text('Express Cold Transport'), findsOneWidget);
    expect(find.text('100% Halal & Hygienic'), findsOneWidget);
    expect(find.text('24/7 Dedicated Support'), findsOneWidget);
  });
}

