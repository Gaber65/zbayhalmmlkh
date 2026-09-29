import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/api/server_strings.dart';

class WhatsAppHelper {
  WhatsAppHelper._();

  static Future<void> launchSupportChat({String? customMessage}) async {
    String number = '966500000000';
    String message = customMessage ?? 'مرحباً، أود الاستفسار عن ذبائح المملكة';

    try {
      final dio = getIt<Dio>();
      final response = await dio.get(ServerStrings.publicSettings);
      final dynamic raw = response.data['data'] ?? response.data;
      if (raw is Map && raw['whatsapp'] is Map) {
        final wa = raw['whatsapp'];
        final isEnabled = wa['enabled'] as bool? ?? true;
        if (!isEnabled) return;

        final rawNumber = (wa['number'] ?? '').toString();
        if (rawNumber.isNotEmpty) {
          number = rawNumber;
        }

        final rawMsg = (wa['default_message'] ?? '').toString();
        if (rawMsg.isNotEmpty && customMessage == null) {
          message = rawMsg;
        }
      }
    } catch (_) {
      // Fall back to default number if settings call fails
    }

    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    final finalNumber = cleanNumber.startsWith('05') ? '966${cleanNumber.substring(1)}' : cleanNumber;

    final encodedMsg = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$finalNumber?text=$encodedMsg');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
