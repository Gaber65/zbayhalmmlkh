import 'package:flutter/foundation.dart' show kIsWeb;

/// Application Configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'ذبائح الممكلة';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Environment
  static const bool isProduction = true;
  static const bool enableLogging = false;

  // Local Server Configuration
  static const String localPort = '8069';
  static const String localIp = '192.168.1.4'; // Tested & verified: returns 200 OK directly

  // API Configuration
  static String get baseUrl {
    if (isProduction) {
      return 'https://api.zbayhalmmlkh.network';
    }

    if (kIsWeb) {
      return 'http://localhost:$localPort';
    }

    // 192.168.1.4 connects directly from both Android Emulator & Physical Phone
    return 'http://$localIp:$localPort';
  }
}

