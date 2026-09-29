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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPhoneMode = true;
  final _identifierController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final input = _identifierController.text.trim();
    final isArabic = context.read<AppCubit>().state.locale.languageCode == 'ar';

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPhoneMode
                ? (isArabic ? 'يرجى إدخال رقم الجوال' : 'Please enter your phone number')
                : S.of(context).email_hint,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String finalIdentifier = input;
    if (_isPhoneMode) {
      String cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]+'), '');
      if (cleaned.startsWith('05')) {
        finalIdentifier = '+966${cleaned.substring(1)}';
      } else if (cleaned.startsWith('5')) {
        finalIdentifier = '+966$cleaned';
      } else if (!cleaned.startsWith('+966')) {
        finalIdentifier = '+966$cleaned';
      } else {
        finalIdentifier = cleaned;
      }
    }

    context.read<AuthCubit>().register(finalIdentifier);
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
                            isArabic ? 'إنشاء حساب جديد' : 'Create Account',
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
                            isArabic
                                ? 'انضم إلى ذبائح المملكة للاستمتاع بتجربة طلب فاخرة وطازجة.'
                                : 'Join Dhabayih Lmamlaka for a fresh luxury shopping experience.',
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
                                // Dual Channel Selector Tabs
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (!_isPhoneMode) {
                                              setState(() {
                                                _isPhoneMode = true;
                                                _identifierController.clear();
                                              });
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: _isPhoneMode
                                                  ? primaryColor
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: _isPhoneMode
                                                  ? [
                                                      BoxShadow(
                                                        color: primaryColor.withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      )
                                                    ]
                                                  : [],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.phone_android_rounded,
                                                  size: 18,
                                                  color: _isPhoneMode
                                                      ? Colors.white
                                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  context.read<AppCubit>().state.locale.languageCode == 'ar'
                                                      ? 'رقم الجوال (SMS)'
                                                      : 'Phone (SMS)',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: _isPhoneMode
                                                        ? Colors.white
                                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_isPhoneMode) {
                                              setState(() {
                                                _isPhoneMode = false;
                                                _identifierController.clear();
                                              });
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: !_isPhoneMode
                                                  ? primaryColor
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: !_isPhoneMode
                                                  ? [
                                                      BoxShadow(
                                                        color: primaryColor.withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      )
                                                    ]
                                                  : [],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.mail_outline_rounded,
                                                  size: 18,
                                                  color: !_isPhoneMode
                                                      ? Colors.white
                                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  context.read<AppCubit>().state.locale.languageCode == 'ar'
                                                      ? 'البريد الإلكتروني'
                                                      : 'Email',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: !_isPhoneMode
                                                        ? Colors.white
                                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Text(
                                  _isPhoneMode
                                      ? (context.read<AppCubit>().state.locale.languageCode == 'ar'
                                          ? 'رقم الجوال'
                                          : 'Phone Number')
                                      : S.of(context).email_label,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: onSurfaceColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 10),

                                // Dynamic Input Field (Phone or Email)
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
                                      color: _inputFocus.hasFocus
                                          ? primaryColor
                                          : Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.3),
                                      width: _inputFocus.hasFocus ? 1.5 : 1.0,
                                    ),
                                    boxShadow: _inputFocus.hasFocus
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
                                    controller: _identifierController,
                                    focusNode: _inputFocus,
                                    keyboardType: _isPhoneMode
                                        ? TextInputType.phone
                                        : TextInputType.emailAddress,
                                    textDirection: _isPhoneMode ? TextDirection.ltr : null,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: onSurfaceColor,
                                          fontWeight: _isPhoneMode ? FontWeight.bold : FontWeight.normal,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: _isPhoneMode
                                          ? '05X XXX XXXX'
                                          : S.of(context).email_hint,
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.5),
                                          ),
                                      prefixIcon: _isPhoneMode
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text('🇸🇦', style: TextStyle(fontSize: 18)),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '+966',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: onSurfaceColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    width: 1,
                                                    height: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline
                                                        .withOpacity(0.3),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Icon(
                                              Icons.mail_outline_rounded,
                                              color: _inputFocus.hasFocus
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

                                // Submit Register Button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : _handleRegister,
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
                                                        ? 'إنشاء الحساب'
                                                        : 'Create Account',
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

                                // Back to Login Outlined Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: () => context.pop(),
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
                                          Icons.login_rounded,
                                          size: 20,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isArabic
                                              ? 'تسجيل الدخول للحساب الحالي'
                                              : 'Sign In to Existing Account',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 14,
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
