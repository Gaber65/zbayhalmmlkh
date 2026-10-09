import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/core/app_cubit/app_cubit.dart';
import 'package:dhabayih_lmamlaka/core/app_cubit/app_state.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/widgets/responsive_layout.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_state.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/profile_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/profile_state.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/highlight_cubit.dart';

import 'widgets/mobile/profile_mobile_view.dart';
import 'widgets/web/profile_web_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final bool isGuest = authState is! AuthAuthenticated;

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                final cubit = getIt<ProfileCubit>();
                if (!isGuest) {
                  cubit.fetchProfile();
                }
                return cubit;
              },
            ),
            BlocProvider(
              create: (context) => getIt<HighlightCubit>(),
            ),
          ],
          child: BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded) {
                final appCubit = context.read<AppCubit>();
                final profile = state.profile;

                // Fetch Highlights for the user
                context.read<HighlightCubit>().fetchMyHighlights(profile.id);

                // Sync theme
                final profileTheme = profile.preferredTheme;
                final currentThemeMode = appCubit.state.themeMode;
                if (profileTheme == 'dark' && currentThemeMode != ThemeMode.dark) {
                  appCubit.changeTheme(ThemeMode.dark);
                } else if (profileTheme == 'light' && currentThemeMode != ThemeMode.light) {
                  appCubit.changeTheme(ThemeMode.light);
                }

                // Sync language
                final profileLang = profile.preferredLanguage;
                final currentLang = appCubit.state.locale.languageCode;
                if (profileLang.isNotEmpty && profileLang != currentLang) {
                  appCubit.changeLanguage(profileLang);
                }
              }
            },
            child: BlocBuilder<AppCubit, AppState>(
              builder: (context, appState) {
                final isDark = appState.themeMode == ThemeMode.dark;
                final isAr = appState.locale.languageCode == 'ar';

                return Scaffold(
                  backgroundColor: colorScheme.surface,
                  appBar: AppBar(
                    backgroundColor: colorScheme.surface,
                    elevation: 0,
                    title: Text(
                      S.of(context).profile,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  body: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      return ResponsiveLayout(
                        mobile: ProfileMobileView(
                          state: state,
                          isGuest: isGuest,
                          isAr: isAr,
                          isDark: isDark,
                          theme: theme,
                          colorScheme: colorScheme,
                        ),
                        desktop: ProfileWebView(
                          state: state,
                          isGuest: isGuest,
                          isAr: isAr,
                          isDark: isDark,
                          theme: theme,
                          colorScheme: colorScheme,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
