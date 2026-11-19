import 'package:flutter/material.dart';
import '../services/app_update_service.dart';
import '../theme/colors.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;
  final VoidCallback onUpdatePressed;

  const AppUpdateDialog({
    super.key,
    required this.updateInfo,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isForce = updateInfo.forceUpdate;
    final isArabic = Localizations.maybeLocaleOf(context)?.languageCode != 'en';

    return PopScope(
      canPop: !isForce,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon & Visual Badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: isForce
                      ? AppColors.primaryContainer
                      : AppColors.goldContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isForce
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.gold.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isForce
                      ? Icons.system_update_rounded
                      : Icons.upgrade_rounded,
                  size: 40,
                  color: isForce ? AppColors.primary : AppColors.goldDark,
                ),
              ),
              const SizedBox(height: 18),

              // 2. Badge: Force vs Optional
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isForce
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isForce
                      ? (isArabic ? 'تحديث إجباري مطلوب' : 'Mandatory Update')
                      : (isArabic ? 'تحديث جديد متاح' : 'Optional Update'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isForce ? AppColors.primary : AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Title
              Text(
                updateInfo.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 10),

              // 4. Message description
              Text(
                updateInfo.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // 5. Version Info Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isArabic ? "الإصدار الحالي" : "Current"}: ${updateInfo.currentVersion}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isArabic ? Icons.arrow_back : Icons.arrow_forward,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${isArabic ? "الجديد" : "Latest"}: ${updateInfo.latestVersion}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: onUpdatePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'تحديث التطبيق الآن' : 'Update App Now',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isForce) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(
                        isArabic ? 'لاحقاً (تخطي)' : 'Later (Skip)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

