import 'package:dhabayih_lmamlaka/features/user/profile/domain/entities/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/core/app_cubit/app_cubit.dart';
import 'package:dhabayih_lmamlaka/core/config/app_config.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/profile_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/profile_state.dart';
import 'package:dhabayih_lmamlaka/core/utils/whatsapp_helper.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/domain/entities/user_type.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../edit_profile_bottom_sheet.dart';
import 'profile_highlights_strip.dart';
import 'profile_avatar_highlight.dart';

class ProfileMobileView extends StatelessWidget {
  final ProfileState state;
  final bool isGuest;
  final bool isAr;
  final bool isDark;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const ProfileMobileView({
    super.key,
    required this.state,
    required this.isGuest,
    required this.isAr,
    required this.isDark,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return _buildGuestBody(context);
    }

    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProfileError) {
      return _buildErrorBody(context, (state as ProfileError).message);
    } else if (state is ProfileLoaded) {
      return _buildLoadedBody(context, (state as ProfileLoaded).profile);
    }

    return const SizedBox.shrink();
  }

  Widget _buildGuestBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  size: 100,
                  color: colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).guest_user,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).guest_subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go(Routes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    S.of(context).login_register,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              S.of(context).general_settings,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsSection(
            context,
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.language_rounded,
                title: S.of(context).app_language,
                subtitle: isAr ? S.of(context).arabic : S.of(context).english,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAr ? '🇺🇦 EN' : '🇸🇦 AR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  final targetLang = isAr ? 'en' : 'ar';
                  context.read<AppCubit>().changeLanguage(targetLang);
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: S.of(context).dark_mode,
                subtitle: isDark
                    ? S.of(context).enabled
                    : S.of(context).disabled,
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) {
                    context.read<AppCubit>().toggleTheme();
                  },
                  activeTrackColor: colorScheme.primary,
                ),
                onTap: () {
                  context.read<AppCubit>().toggleTheme();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ProfileCubit>().fetchProfile(),
              child: Text(S.of(context).retry_button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, UserProfile profile) {
    final authState = context.read<AuthCubit>().state;
    final bool isAdmin = (authState is AuthAuthenticated && authState.user.userType == UserType.admin) ||
        profile.userType.trim().toLowerCase() == 'admin';

    final avatar = profile.avatarUrl.isNotEmpty
        ? (profile.avatarUrl.startsWith('http')
              ? profile.avatarUrl
              : "${AppConfig.baseUrl}/${profile.avatarUrl}")
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                ProfileAvatarHighlight(
                  radius: 50,
                  ringGap: 3,
                  ringWidth: 3.5,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: colorScheme.onPrimary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Highlights Strip
          ProfileHighlightsStrip(profile: profile),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).loyalty_points,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context).points_count(profile.loyaltyPoints),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              S.of(context).general_settings,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsSection(
            context,
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.language_rounded,
                title: S.of(context).app_language,
                subtitle: isAr ? S.of(context).arabic : S.of(context).english,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAr ? '🇺🇦 EN' : '🇸🇦 AR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  final targetLang = isAr ? 'en' : 'ar';
                  context.read<AppCubit>().changeLanguage(targetLang);
                  context.read<ProfileCubit>().updateProfile(
                    preferredLanguage: targetLang,
                  );
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: S.of(context).dark_mode,
                subtitle: isDark
                    ? S.of(context).enabled
                    : S.of(context).disabled,
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) {
                    context.read<AppCubit>().toggleTheme();
                    context.read<ProfileCubit>().updateProfile(
                      preferredTheme: val ? 'dark' : 'light',
                    );
                  },
                  activeTrackColor: colorScheme.primary,
                ),
                onTap: () {
                  context.read<AppCubit>().toggleTheme();
                  context.read<ProfileCubit>().updateProfile(
                    preferredTheme: !isDark ? 'dark' : 'light',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsSection(
            context,
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.person_outline_rounded,
                title: S.of(context).edit_profile,
                onTap: () => EditProfileBottomSheet.show(context, profile),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                icon: Icons.history_rounded,
                title: S.of(context).order_history,
                onTap: () => context.push(Routes.orders),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                icon: Icons.location_on_outlined,
                title: S.of(context).saved_addresses,
                onTap: () => context.push(Routes.addresses),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                icon: Icons.chat_rounded,
                customLeading: SvgPicture.asset(
                  'assets/images/whatsapp_logo.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(Color(0xFF25D366), BlendMode.srcIn),
                ),
                title: 'خدمة العملاء (واتساب)',
                subtitle: 'تواصل مباشر مع خدمة عملاء ذبائح المملكة',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF16A34A)),
                onTap: () => WhatsAppHelper.launchSupportChat(),
              ),
              if (isAdmin) ...[
                const Divider(height: 1),
                _buildSettingsTile(
                  context,
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'لوحة إدارة التطبيق (الأدمن)',
                  subtitle: 'إدارة المنتجات، الطلبات، الأقسام، والكوبونات',
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFC59A3F)),
                  onTap: () => context.go(Routes.adminDashboard),
                ),
              ],
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {
                  context.read<AuthCubit>().logout();
                  context.go(Routes.login);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).logout,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    Widget? customLeading,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: customLeading ?? Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            isAr
                ? Icons.arrow_back_ios_new_rounded
                : Icons.arrow_forward_ios_rounded,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
    );
  }
}
