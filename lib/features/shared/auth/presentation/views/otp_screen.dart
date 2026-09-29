import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:dhabayih_lmamlaka/core/app_cubit/app_cubit.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/core/widgets/ambient_glow.dart';
import 'package:dhabayih_lmamlaka/core/widgets/responsive_layout.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';
import '../../domain/entities/user_type.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final bool isLogin;
  const OtpScreen({super.key, required this.email, required this.isLogin});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handleVerify() {
    final otp = _controllers.map((c) => c.text).join('');
    if (otp.length < 6) {
      final isArabic =
          context.read<AppCubit>().state.locale.languageCode == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'يرجى إدخال رمز التحقق المكون من 6 أرقام'
                : 'Please enter the 6-digit OTP code',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthCubit>().verifyOtp(
      widget.email,
      otp,
      isLogin: widget.isLogin,
    );
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
    final isArabic =
        context.watch<AppCubit>().state.locale.languageCode == 'ar';
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
              // Top Bar Actions
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button & Theme Switcher
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: onSurfaceColor,
                            size: 20,
                          ),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: 4),
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
                              size: 18,
                            ),
                          ),
                          tooltip: 'Toggle Theme',
                        ),
                      ],
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
                        context.read<AppCubit>().changeLanguage(
                          isArabic ? 'en' : 'ar',
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
                        isArabic ? 'English' : 'العربية',
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
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Lock Icon Badge
                          Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              padding: const EdgeInsets.all(20),
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
                              child: Icon(
                                Icons.mark_email_read_outlined,
                                size: 42,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Welcome Headlines
                          Text(
                            isArabic ? 'رمز التحقق (OTP)' : 'Verification Code',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: onSurfaceColor,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isArabic
                                ? 'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى:\n${widget.email}'
                                : 'Enter the 6-digit verification code sent to:\n${widget.email}',
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
                              children: [
                                // 6-Digit OTP Fields Grid
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(6, (index) {
                                      final isFocused =
                                          _focusNodes[index].hasFocus;
                                      final hasText =
                                          _controllers[index].text.isNotEmpty;

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: 50,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                    .withOpacity(0.6)
                                              : AppColors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: isFocused
                                                ? primaryColor
                                                : hasText
                                                ? primaryColor.withOpacity(0.6)
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .outline
                                                      .withOpacity(0.3),
                                            width: isFocused ? 2.0 : 1.0,
                                          ),
                                          boxShadow: isFocused
                                              ? [
                                                  BoxShadow(
                                                    color: primaryColor
                                                        .withOpacity(0.2),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Center(
                                          child: TextField(
                                            controller: _controllers[index],
                                            focusNode: _focusNodes[index],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            maxLength: 1,
                                            onChanged: (val) =>
                                                _onChanged(val, index),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: onSurfaceColor,
                                            ),
                                            decoration: const InputDecoration(
                                              counterText: '',
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Verify Submit Button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : _handleVerify,
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
                                                    isArabic
                                                        ? 'تأكيد الحساب'
                                                        : 'Verify Account',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.verified_user_rounded,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Resend Code Option
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isArabic
                                    ? 'لم يصلك كود التحقق؟'
                                    : "Didn't receive code?",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<AuthCubit>().login(widget.email);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isArabic
                                            ? 'تم إعادة إرسال رمز التحقق'
                                            : 'OTP code has been resent',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Text(
                                  isArabic ? 'إعادة الإرسال' : 'Resend Code',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
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
