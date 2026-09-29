import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhabayih_lmamlaka/core/app_cubit/app_cubit.dart';
import 'package:dhabayih_lmamlaka/core/app_cubit/app_state.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/widgets/custom_button.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    context.read<AppCubit>().setFirstLaunchCompleted();
    context.go(Routes.login);
  }

  void _changeLanguage(String languageCode) {
    context.read<AppCubit>().changeLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        final currentLang = appState.locale.languageCode;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Stack(
            children: [
              // Background Image half screen
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.55,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDE1xxGjhrE3E3RzaPK3Ma1NBrj7H7ieWgOXbWa5FcX5eQCUSB8P7iW5TDCxCL_tgmlVYmsvu-PCKX0zd-y_0xClVJWOibqfu-w77SHJ62sjI3fXpHTzUvKSRjHw0ALc8aX5VXwo3VjK9oa1yXtYuWcBFxf7yypEqJfWnSg43NnHiRTy2EivjPmPYOnVeTTfJPRp56_6uKVONEDPB35iHIpDaCaP6xTs-3BzGZ0IzCQOqZeMkbs-cmE5CCz-3DCj7hFypcXIvb9BoZ5',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.surface.withValues(alpha: 0.0),
                          colorScheme.surface,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),

              // Main Layout Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const Spacer(),

                          // Content Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32.0),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.eco_rounded,
                                    size: 40,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Headline
                                Text(
                                  S.of(context).welcome,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  S.of(context).welcome_headline,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Features Checklist
                                _buildFeatureRow(
                                  context,
                                  Icons.verified_user_outlined,
                                  S.of(context).onboarding_feature_1,
                                ),
                                const SizedBox(height: 16),
                                _buildFeatureRow(
                                  context,
                                  Icons.local_shipping_outlined,
                                  S.of(context).onboarding_feature_2,
                                ),
                                const SizedBox(height: 16),
                                _buildFeatureRow(
                                  context,
                                  Icons.sanitizer_outlined,
                                  S.of(context).onboarding_feature_3,
                                ),

                                const SizedBox(height: 40),

                                // Primary Button - Get Started
                                CustomButton(
                                  text: S.of(context).get_started,
                                  onPressed: _navigateToLogin,
                                  color: colorScheme.primary,
                                  textColor: colorScheme.onPrimary,
                                ),

                                const SizedBox(height: 24),

                                // Floating Language Selection Pill
                                Container(
                                  width: 240,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      // English Option
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _changeLanguage('en'),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: currentLang == 'en'
                                                  ? colorScheme.surface
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              boxShadow: currentLang == 'en'
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.05),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Text(
                                              S.of(context).english,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: currentLang == 'en'
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: currentLang == 'en'
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Arabic Option
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _changeLanguage('ar'),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: currentLang == 'ar'
                                                  ? colorScheme.surface
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              boxShadow: currentLang == 'ar'
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.05),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Text(
                                              S.of(context).arabic,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: currentLang == 'ar'
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: currentLang == 'ar'
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
