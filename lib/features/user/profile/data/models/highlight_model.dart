import 'package:dhabayih_lmamlaka/core/config/app_config.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';

/// JSON model for a single highlight item returned by the Odoo API.
///
/// Example response shape:
/// ```json
/// {
///   "id": 12,
///   "name": "Eid 2025",
///   "media_type": "image",
///   "media_url": "https://…/image.jpg"
/// }
/// ```
class HighlightModel {
  final int id;
  final String name;
  final String mediaType;
  final String mediaUrl;

  const HighlightModel({
    required this.id,
    required this.name,
    required this.mediaType,
    required this.mediaUrl,
  });

  factory HighlightModel.fromJson(Map<String, dynamic> json) {
    String rawMediaUrl = json['media_url'] as String? ?? '';
    if (rawMediaUrl.isNotEmpty && !rawMediaUrl.startsWith('http')) {
      String base = AppConfig.baseUrl;
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      if (!rawMediaUrl.startsWith('/')) rawMediaUrl = '/$rawMediaUrl';
      rawMediaUrl = '$base$rawMediaUrl';
    }
    
    return HighlightModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? 'image',
      mediaUrl: rawMediaUrl,
    );
  }

  HighlightEntity toDomain() {
    return HighlightEntity(
      id: id,
      name: name,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
    );
  }
}
