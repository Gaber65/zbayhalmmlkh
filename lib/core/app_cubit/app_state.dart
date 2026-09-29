import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isFirstLaunch;
  final bool isLoading;

  const AppState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('ar'),
    this.isFirstLaunch = true,
    this.isLoading = false,
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;

  AppState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isFirstLaunch,
    bool? isLoading,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, isFirstLaunch, isLoading];
}
