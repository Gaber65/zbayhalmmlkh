import 'dart:math' as math;

import 'package:dhabayih_lmamlaka/features/shared/auth/domain/entities/user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhabayih_lmamlaka/core/app_cubit/app_cubit.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_state.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';

// ─── Elite Splash Screen ────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  late AnimationController _masterController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  // ── Animations ───────────────────────────────────────────────────────────
  late Animation<double> _bgFade;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _dividerWidth;
  late Animation<double> _shimmerPos;
  late Animation<double> _pulseScale;

  bool _animationCompleted = false;

  // ── Particle data ─────────────────────────────────────────────────────────
  final List<_Particle> _particles = List.generate(
    14,
    (i) => _Particle(
      angle: (i / 14) * 2 * math.pi,
      radius: 100 + (i % 3) * 28.0,
      size: 2.0 + (i % 4) * 1.5,
      speed: 0.4 + (i % 3) * 0.15,
      opacity: 0.3 + (i % 3) * 0.2,
    ),
  );

  @override
  void initState() {
    super.initState();
    _buildControllers();
    _buildAnimations();
    _startSequence();
  }

  void _buildControllers() {
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  void _buildAnimations() {
    _bgFade = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );
    _ringScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.05, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.05, 0.35, curve: Curves.easeIn),
      ),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.15, 0.5, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.15, 0.4, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.4, 0.65, curve: Curves.easeIn),
      ),
    );
    _dividerWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.65, 0.9, curve: Curves.easeIn),
      ),
    );
    _shimmerPos = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
    _pulseScale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startSequence() {
    _masterController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _progressController.forward();
    });
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        _animationCompleted = true;
        _checkAndNavigate();
      }
    });
  }

  void _checkAndNavigate() {
    if (!_animationCompleted) return;

    final appState = context.read<AppCubit>().state;
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthLoading || authState is AuthInitial) return;

    final bool hasSeenOnboarding = !appState.isFirstLaunch;

    if (hasSeenOnboarding) {
      if (authState is AuthAuthenticated) {
        final userType = authState.user.userType;
        if (userType == UserType.admin) {
          context.go(Routes.adminDashboard);
        } else {
          context.go(Routes.home);
        }
      } else {
        context.go(Routes.login);
      }
    } else {
      context.go(Routes.onboarding);
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) => _checkAndNavigate(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0205),
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _masterController,
            _particleController,
            _shimmerController,
            _pulseController,
            _progressController,
          ]),
          builder: (context, _) {
            return Stack(
              children: [
                _buildBackground(),
                _buildDecorativeRings(),
                _buildParticles(),
                _buildCenterContent(context),
                _buildBottomBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Background ──────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return FadeTransition(
      opacity: _bgFade,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.4,
            colors: [
              Color(0xFF3D0A10),
              Color(0xFF1A0408),
              Color(0xFF080104),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  // ─── Decorative rings ─────────────────────────────────────────────────────
  Widget _buildDecorativeRings() {
    return Center(
      child: ScaleTransition(
        scale: _ringScale,
        child: Opacity(
          opacity: _ringOpacity.value,
          child: SizedBox(
            width: 340,
            height: 340,
            child: CustomPaint(painter: _RingPainter()),
          ),
        ),
      ),
    );
  }

  // ─── Orbiting gold particles ──────────────────────────────────────────────
  Widget _buildParticles() {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final t = _particleController.value;

    return Stack(
      children: _particles.map((p) {
        final angle = p.angle + t * 2 * math.pi * p.speed;
        final x = cx + math.cos(angle) * p.radius;
        final y = cy + math.sin(angle) * p.radius;
        final fade = (_ringOpacity.value * p.opacity).clamp(0.0, 1.0);
        return Positioned(
          left: x - p.size / 2,
          top: y - p.size / 2,
          child: Opacity(
            opacity: fade,
            child: Container(
              width: p.size,
              height: p.size,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Center content ───────────────────────────────────────────────────────
  Widget _buildCenterContent(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            _buildLogo(),
            const SizedBox(height: 36),
            _buildTitle(context),
            const SizedBox(height: 12),
            _buildDivider(),
            const SizedBox(height: 12),
            _buildTagline(context),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _logoScale,
      child: FadeTransition(
        opacity: _logoOpacity,
        child: ScaleTransition(
          scale: _pulseScale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 192,
                height: 192,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Inner ring
              Container(
                width: 176,
                height: 176,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.35),
                    width: 1.2,
                  ),
                ),
              ),
              // Logo with shimmer
              ClipOval(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(_shimmerPos.value - 1, -0.5),
                      end: Alignment(_shimmerPos.value, 0.5),
                      colors: const [
                        Colors.transparent,
                        Color(0x55FFFFFF),
                        Colors.transparent,
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2C0A0F), Color(0xFF1A0508)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // Gold top dot
              Positioned(
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD700),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.7),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _titleSlide.value),
      child: Opacity(
        opacity: _titleOpacity.value,
        child: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFF0A0), Color(0xFFE8B800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Text(
            'ذبائح المملكة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Opacity(
      opacity: _dividerWidth.value,
      child: ClipRect(
        child: Align(
          alignment: Alignment.center,
          widthFactor: _dividerWidth.value,
          child: SizedBox(
            width: 200,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 0.8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xFFFFD700)],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.star, size: 8, color: Color(0xFFFFD700)),
                ),
                Expanded(
                  child: Container(
                    height: 0.8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Colors.transparent],
                      ),
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

  Widget _buildTagline(BuildContext context) {
    return Opacity(
      opacity: _taglineOpacity.value,
      child: Text(
        S.of(context).splash_tagline,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 5.0,
          color: const Color(0xFFFFD700).withOpacity(0.7),
        ),
      ),
    );
  }

  // ─── Bottom progress bar ──────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Stack(
                  children: [
                    Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _progressController.value,
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFF0A0)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: _taglineOpacity.value,
                child: Text(
                  S.of(context).crafted_by,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Colors.white.withOpacity(0.3),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Particle model ───────────────────────────────────────────────────────────
class _Particle {
  final double angle;
  final double radius;
  final double size;
  final double speed;
  final double opacity;

  const _Particle({
    required this.angle,
    required this.radius,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// ─── Ring painter ─────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final rings = [
      _RingSpec(radius: 148, strokeWidth: 0.5, opacity: 0.25),
      _RingSpec(radius: 120, strokeWidth: 0.8, opacity: 0.18),
      _RingSpec(radius: 92, strokeWidth: 0.5, opacity: 0.12),
    ];

    for (final ring in rings) {
      final paint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(ring.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth;
      canvas.drawCircle(center, ring.radius, paint);
    }

    // Corner arc ticks on outer ring
    final tickPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final angle = (i / 4) * 2 * math.pi - math.pi / 4;
      final rect = Rect.fromCircle(center: center, radius: 148);
      canvas.drawArc(rect, angle - 0.18, 0.36, false, tickPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => false;
}

class _RingSpec {
  final double radius;
  final double strokeWidth;
  final double opacity;

  const _RingSpec({
    required this.radius,
    required this.strokeWidth,
    required this.opacity,
  });
}
