/// Entry point for the Dhabayih Lmamlaka Flutter application.
///
/// This file initializes core application services including system configuration,
/// Firebase initialization, dependency injection, push notifications, state management,
/// and sets up the root widget tree with localizations and routing.
library;

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/app_cubit/app_cubit.dart';
import 'core/app_cubit/app_state.dart';
import 'features/shared/auth/presentation/manager/auth_cubit.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'generated/l10n.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';

/// Top-level background message handler for Firebase Cloud Messaging (FCM).
///
/// Must be annotated with `@pragma('vm:entry-point')` so it can be called
/// in an isolated background thread when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

/// The main entry point of the Flutter app.
///
/// Performs global app initialization before launching [MyApp]:
/// 1. Ensures Flutter widget bindings are initialized.
/// 2. Locks app orientation to portrait mode.
/// 3. Sets transparent status bar UI overlay style.
/// 4. Initializes Firebase services for current platform.
/// 5. Registers dependencies via getIt service locator.
/// 6. Configures FCM permissions and notification handlers on native platforms.
/// 7. Launches [MyApp] wrapped with global BLoC providers.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize dependency injection
  await configureDependencies();

  if (!kIsWeb) {
    await FirebaseMessaging.instance.requestPermission();
    await NotificationService().init();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      NotificationService().showNotification(event);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {});
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (context) => getIt<AppCubit>()),
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
///
/// Handles screen utility setup ([ScreenUtilInit]), global application state listening
/// ([BlocBuilder] listening to [AppCubit]), theme mode switching, localization setup,
/// and router configuration using GoRouter via [MaterialApp.router].
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<AppCubit, AppState>(
          // Only rebuild when themeMode or locale changes, not on every state.
          buildWhen: (prev, next) =>
              prev.themeMode != next.themeMode || prev.locale != next.locale,
          builder: (context, state) {
            return MaterialApp.router(
              scrollBehavior: AppScrollBehavior(),
              onGenerateTitle: (context) => S.of(context).app_name,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.themeMode,
              routerConfig: AppRouter.router,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              locale: state.locale,
            );
          },
        );
      },
    );
  }
}

/// Custom scroll behavior for the application.
///
/// Enables drag and scroll gestures across touch, mouse, trackpad, and stylus devices,
/// ensuring consistent multi-platform user interaction (especially on Web and Desktop).
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
