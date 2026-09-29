import 'package:dhabayih_lmamlaka/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../../domain/entities/home_data.dart';

class UserHighlightWidget extends StatelessWidget {
  final UserHighlight? userHighlight;
  final String? deliveryLocation;
  final VoidCallback? onLocationTap;

  const UserHighlightWidget({
    super.key,
    this.userHighlight,
    this.deliveryLocation,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (userHighlight == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: userHighlight!.avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: "${AppConfig.baseUrl}/${userHighlight!.avatarUrl}",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    )
                  : Container(
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
            ),
          ),
        ),

        // Location Pill
        const SizedBox(width: 16),

        Material(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).current_location,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        deliveryLocation ?? S.of(context).default_location_mock,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),

        // User Profile Avatar
      ],
    );
  }
}
