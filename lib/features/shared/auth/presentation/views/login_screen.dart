import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:dhabayih_lmamlaka/core/app_cubit/app_cubit.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/widgets/ambient_glow.dart';
import 'package:dhabayih_lmamlaka/core/widgets/responsive_layout.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../../../../core/theme/colors.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';
import '../../domain/entities/user_type.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).email_hint),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthCubit>().login(email);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthOtpSent) {
          context.push(
            Routes.otp,
            extra: {'email': state.email, 'isLogin': state.isLogin},
          );
        } else if (state is AuthAuthenticated) {
          if (state.user.userType == UserType.admin) {
            context.go(Routes.adminDashboard);
          } else {
            context.go(Routes.home);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: ResponsiveLayout(
          mobile: _buildMobileLayout(context, isDark),
          desktop: _buildDesktopLayout(context, isDark),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(flex: 6, child: _buildMobileLayout(context, isDark)),
        Expanded(
          flex: 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB4SUMC85bcy7WImIEzfhveZPfQDb8xPatcyXrZP6yem66hcOA9Wymk57PqWhrBTXHKcE-NTigIyS5shW-r9mExBj5e6PRTBx7ougHWXvV2FwraoNocxQn9gNNFBuT991Ch30ALjATXPzeToe8ireFbwXvyXtmikoUUX9aT-dEmuw1Ab_cwD5lo8QW6XFxXgrRG6jWEqG1psosOPISaBE-Dasib4NsQ796eUY0tsrtIivpWM_AHCz9nbcNC8WUC1jteCXeVUk_CYRf7',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final containerColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4)
        : Colors.white;

    return Stack(
      children: [
        // Background Ambient Glows
        Positioned(
          top: -180,
          left: -180,
          child: RepaintBoundary(
            child: AmbientGlow(
              color: primaryColor.withOpacity(0.25),
              duration: const Duration(seconds: 8),
            ),
          ),
        ),
        Positioned(
          bottom: -180,
          right: -180,
          child: RepaintBoundary(
            child: AmbientGlow(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              duration: const Duration(seconds: 10),
            ),
          ),
        ),

        // Custom Dot Grid Background Accent
        Positioned.fill(
          child: Opacity(
            opacity: isDark ? 0.15 : 0.25,
            child: CustomPaint(
              painter: _DotPatternPainter(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
        ),

        // Main Content View
        SafeArea(
          child: Column(
            children: [
              // Top Bar Actions (Theme Toggle & Language Switch)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Theme Switcher Button
                    IconButton(
                      onPressed: () {
                        context.read<AppCubit>().toggleTheme();
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      tooltip: 'Toggle Theme',
                    ),

                    // Brand Title Header
                    Text(
                      S.of(context).app_name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),

                    // Language Toggle Button
                    TextButton(
                      onPressed: () {
                        final currentLang = context
                            .read<AppCubit>()
                            .state
                            .locale
                            .languageCode;
                        context.read<AppCubit>().changeLanguage(
                          currentLang == 'ar' ? 'en' : 'ar',
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : primaryColor.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        context.watch<AppCubit>().state.locale.languageCode ==
                                'ar'
                            ? 'English'
                            : 'العربية',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand Logo Badge
                          Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? surfaceColor : Colors.white,
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.12),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Welcome Headlines
                          Text(
                            S.of(context).login_welcome,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: onSurfaceColor,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            S.of(context).login_subtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 36),

                          // Elevated Professional Card Form
                          Container(
                            padding: const EdgeInsets.all(28.0),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withOpacity(0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.3 : 0.05,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).email_label,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: onSurfaceColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 10),

                                // Email Input Field
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.surface.withOpacity(0.6)
                                        : AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _emailFocus.hasFocus
                                          ? primaryColor
                                          : Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.3),
                                      width: _emailFocus.hasFocus ? 1.5 : 1.0,
                                    ),
                                    boxShadow: _emailFocus.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    keyboardType: TextInputType.emailAddress,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: onSurfaceColor),
                                    decoration: InputDecoration(
                                      hintText: S.of(context).email_hint,
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.5),
                                          ),
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                        color: _emailFocus.hasFocus
                                            ? primaryColor
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        size: 22,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Submit Button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: isDark ? 0 : 4,
                                          shadowColor: primaryColor.withOpacity(
                                            0.4,
                                          ),
                                        ),
                                        child: isLoading
                                            ? SizedBox(
                                                height: 22,
                                                width: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.onPrimary,
                                                      ),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    S.of(context).sign_in,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Register Outlined Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        context.push(Routes.register),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: primaryColor.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_add_outlined,
                                          size: 20,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          context
                                                      .watch<AppCubit>()
                                                      .state
                                                      .locale
                                                      .languageCode ==
                                                  'ar'
                                              ? 'إنشاء حساب جديد'
                                              : 'Create New Account',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Guest Access Link
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(Routes.home),
                              child: Text(
                                S.of(context).continue_as_guest,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Footer Terms & Privacy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  S.of(context).privacy_policy,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.7),
                                      ),
                                ),
                              ),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.4),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  S.of(context).terms_of_service,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.7),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  final Color color;
  _DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double spacing = 36.0;
    const double radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
