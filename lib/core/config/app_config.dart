import 'package:flutter/foundation.dart' show kIsWeb;

/// Application Configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'ذبائح المملكة';
  static const String appVersion = '1.0.1';
  static const String buildNumber = '2';

  // Environment
  static const bool isProduction = true;
  static const bool enableLogging = true;

  // Local Server Configuration
  static const String localPort = '8069';
  static const String localIp = '192.168.1.6';

  // API Configuration
  static String get baseUrl {
    if (isProduction) {
      return 'https://api.zbayhalmmlkh.network';
    }

    // Connects directly via adb reverse or localhost on Windows / Web / Emulator
    return 'http://127.0.0.1:$localPort';
  }
}
