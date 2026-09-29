import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/core/app_cubit/app_cubit.dart';
import 'package:dhabayih_lmamlaka/core/config/app_config.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/domain/entities/profile.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/profile_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/profile/presentation/manager/profile_state.dart';
import '../edit_profile_bottom_sheet.dart';

class ProfileWebView extends StatelessWidget {
  final ProfileState state;
  final bool isGuest;
  final bool isAr;
  final bool isDark;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const ProfileWebView({
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
      return _buildGuestWebBody(context);
    }

    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProfileError) {
      return _buildErrorWebBody(context, (state as ProfileError).message);
    } else if (state is ProfileLoaded) {
      return _buildLoadedWebBody(context, (state as ProfileLoaded).profile);
    }

    return const SizedBox.shrink();
  }

  Widget _buildGuestWebBody(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  size: 120,
                  color: colorScheme.outlineVariant,
                ),
                const SizedBox(height: 24),
                Text(
                  S.of(context).guest_user,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(context).guest_subtitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go(Routes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
        ),
      ),
    );
  }

  Widget _buildErrorWebBody(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ProfileCubit>().fetchProfile(),
            child: Text(S.of(context).retry_button),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedWebBody(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: User Card & Loyalty Points
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildUserWebCard(context, profile),
                    const SizedBox(height: 24),
                    _buildLoyaltyWebCard(context, profile),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // Right Column: Settings & Navigation
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWebSectionTitle(context, S.of(context).general_settings),
                    _buildWebSettingsCard(context),
                    const SizedBox(height: 40),
                    _buildWebSectionTitle(context, S.of(context).profile),
                    _buildWebNavigationCard(context, profile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserWebCard(BuildContext context, UserProfile profile) {
    final avatar = profile.avatarUrl.isNotEmpty
        ? (profile.avatarUrl.startsWith('http')
            ? profile.avatarUrl
            : "${AppConfig.baseUrl}/${profile.avatarUrl}")
        : '';

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.3)],
                ),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                child: avatar.isEmpty
                    ? Icon(Icons.person, size: 60, color: colorScheme.onPrimary)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              profile.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.email,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  context.go(Routes.login);
                },
                icon: Icon(Icons.logout_rounded, color: colorScheme.error),
                label: Text(
                  S.of(context).logout,
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyWebCard(BuildContext context, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).loyalty_points,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).points_count(profile.loyaltyPoints),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWebSettingsCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildWebListTile(
            context,
            icon: Icons.language_rounded,
            title: S.of(context).app_language,
            subtitle: isAr ? S.of(context).arabic : S.of(context).english,
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ar', label: Text('العربية')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {isAr ? 'ar' : 'en'},
              onSelectionChanged: (Set<String> newSelection) {
                final targetLang = newSelection.first;
                context.read<AppCubit>().changeLanguage(targetLang);
                context.read<ProfileCubit>().updateProfile(preferredLanguage: targetLang);
              },
            ),
          ),
          const Divider(height: 1),
          _buildWebListTile(
            context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: S.of(context).dark_mode,
            subtitle: isDark ? S.of(context).enabled : S.of(context).disabled,
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                context.read<AppCubit>().toggleTheme();
                context.read<ProfileCubit>().updateProfile(preferredTheme: val ? 'dark' : 'light');
              },
              activeTrackColor: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebNavigationCard(BuildContext context, UserProfile profile) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildWebListTile(
            context,
            icon: Icons.person_outline_rounded,
            title: S.of(context).edit_profile,
            showArrow: true,
            onTap: () => EditProfileBottomSheet.show(context, profile),
          ),
          const Divider(height: 1),
          _buildWebListTile(
            context,
            icon: Icons.history_rounded,
            title: S.of(context).order_history,
            showArrow: true,
            onTap: () => context.push(Routes.orders),
          ),
          const Divider(height: 1),
          _buildWebListTile(
            context,
            icon: Icons.location_on_outlined,
            title: S.of(context).saved_addresses,
            showArrow: true,
            onTap: () => context.push(Routes.addresses),
          ),
        ],
      ),
    );
  }

  Widget _buildWebListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (showArrow)
              Icon(
                isAr ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
