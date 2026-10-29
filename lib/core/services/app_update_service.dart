import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../di/injection.dart';
import '../widgets/app_update_dialog.dart';

class AppUpdateInfo {
  final bool updateAvailable;
  final bool forceUpdate;
  final String currentVersion;
  final String latestVersion;
  final String minVersion;
  final String platform;
  final String storeUrl;
  final String title;
  final String message;

  AppUpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.minVersion,
    required this.platform,
    required this.storeUrl,
    required this.title,
    required this.message,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      updateAvailable: json['update_available'] == true,
      forceUpdate: json['force_update'] == true,
      currentVersion: json['current_version']?.toString() ?? '1.0.0',
      latestVersion: json['latest_version']?.toString() ?? '1.0.0',
      minVersion: json['min_version']?.toString() ?? '1.0.0',
      platform: json['platform']?.toString() ?? 'android',
      storeUrl: json['store_url']?.toString() ?? '',
      title: json['title']?.toString() ?? 'تحديث جديد متوفر',
      message: json['message']?.toString() ?? 'يرجى تحديث التطبيق للاستمتاع بأحدث المزايا والتحسينات.',
    );
  }
}

class AppUpdateService {
  AppUpdateService._();

  static const String appVersion = '1.0.0';
  static bool _hasPromptedThisSession = false;

  /// Checks for app update and prompts the user (Force or Optional)
  static Future<AppUpdateInfo?> checkUpdate(
    BuildContext context, {
    bool forceManualCheck = false,
  }) async {
    // Prevent repeated annoying popups in the same session unless it's a manual check
    if (_hasPromptedThisSession && !forceManualCheck) {
      return null;
    }

    try {
      if (!getIt.isRegistered<Dio>()) return null;
      final dio = getIt<Dio>();

      final platform = kIsWeb
          ? 'web'
          : Platform.isIOS
              ? 'ios'
              : 'android';

      if (platform == 'web') return null;

      final isArabic = Localizations.maybeLocaleOf(context)?.languageCode != 'en';
      final lang = isArabic ? 'ar' : 'en';

      final response = await dio.get(
        '/api/v1/app/check_update',
        queryParameters: {
          'platform': platform,
          'version': appVersion,
          'lang': lang,
        },
      );

      final data = response.data['data'] ?? response.data;
      if (data == null) return null;

      final updateInfo = AppUpdateInfo.fromJson(data);

      if (updateInfo.updateAvailable && context.mounted) {
        _hasPromptedThisSession = true;
        await showDialog(
          context: context,
          barrierDismissible: !updateInfo.forceUpdate,
          builder: (dialogCtx) => AppUpdateDialog(
            updateInfo: updateInfo,
            onUpdatePressed: () async {
              final url = Uri.tryParse(updateInfo.storeUrl);
              if (url != null && await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        );
      }

      return updateInfo;
    } catch (e) {
      debugPrint('Error checking app update: $e');
      return null;
    }
  }

  /// Reset session flag (e.g. for testing)
  static void resetSession() {
    _hasPromptedThisSession = false;
  }
}

