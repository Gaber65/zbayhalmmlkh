import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'app_state.dart';

@lazySingleton
class AppCubit extends Cubit<AppState> {
  final SharedPreferences prefs;

  static const String _themePrefKey = 'app_theme_mode';
  static const String _langPrefKey = 'app_language_code';
  static const String _firstLaunchKey = 'is_first_launch';

  AppCubit(this.prefs) : super(const AppState()) {
    initAppPreferences();
  }

  /// Initialize saved user preferences from SharedPreferences
  void initAppPreferences() {
    final savedThemeStr = prefs.getString(_themePrefKey);
    final savedLangCode = prefs.getString(_langPrefKey);
    final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

    ThemeMode mode = ThemeMode.light;
    if (savedThemeStr == 'light') {
      mode = ThemeMode.light;
    } else if (savedThemeStr == 'dark') {
      mode = ThemeMode.dark;
    } else if (savedThemeStr == 'system') {
      mode = ThemeMode.system;
    }

    final Locale locale = savedLangCode != null
        ? Locale(savedLangCode)
        : const Locale('ar');

    emit(state.copyWith(
      themeMode: mode,
      locale: locale,
      isFirstLaunch: isFirstLaunch,
    ));
  }

  /// Change theme mode (Light / Dark / System) and persist
  Future<void> changeTheme(ThemeMode mode) async {
    String prefVal = 'dark';
    if (mode == ThemeMode.light) {
      prefVal = 'light';
    } else if (mode == ThemeMode.system) {
      prefVal = 'system';
    }

    await prefs.setString(_themePrefKey, prefVal);
    emit(state.copyWith(themeMode: mode));
  }

  /// Toggle between Light and Dark theme
  Future<void> toggleTheme() async {
    final nextMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await changeTheme(nextMode);
  }

  /// Change application locale ('ar' or 'en') and persist
  Future<void> changeLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);
    await prefs.setString(_langPrefKey, languageCode);
    emit(state.copyWith(locale: newLocale));
  }

  /// Mark first launch onboarding as completed
  Future<void> setFirstLaunchCompleted() async {
    await prefs.setBool(_firstLaunchKey, false);
    emit(state.copyWith(isFirstLaunch: false));
  }
}
