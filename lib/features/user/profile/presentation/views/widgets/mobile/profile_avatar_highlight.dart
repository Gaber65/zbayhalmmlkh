import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An Instagram-style animated gradient highlight ring around a profile avatar.
///
/// [radius]   – avatar radius (default 50).
/// [ringGap]  – transparent gap between ring and avatar (default 3).
/// [ringWidth]– stroke width of the gradient ring (default 3.5).
/// [animate]  – whether the ring slowly rotates (default true).
/// [colors]   – gradient stop colors (defaults to brand warm gradient).
class ProfileAvatarHighlight extends StatefulWidget {
  final Widget child;
  final double radius;
  final double ringGap;
  final double ringWidth;
  final bool animate;
  final List<Color>? colors;

  const ProfileAvatarHighlight({
    super.key,
    required this.child,
    this.radius = 50,
    this.ringGap = 3,
    this.ringWidth = 3.5,
    this.animate = true,
    this.colors,
  });

  @override
  State<ProfileAvatarHighlight> createState() => _ProfileAvatarHighlightState();
}

class _ProfileAvatarHighlightState extends State<ProfileAvatarHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.animate) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ringColors =
        widget.colors ??
        [
          colorScheme.primary,
          const Color(0xFFFF6B6B),
          const Color(0xFFFFD93D),
          const Color(0xFFFF8C42),
          colorScheme.primary,
        ];

    final totalSize = (widget.radius + widget.ringGap + widget.ringWidth) * 2;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(
            painter: _RingPainter(
              colors: ringColors,
              ringWidth: widget.ringWidth,
              sweepAngle: _ctrl.value * 2 * math.pi,
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.ringGap + widget.ringWidth),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<Color> colors;
  final double ringWidth;
  final double sweepAngle;

  _RingPainter({
    required this.colors,
    required this.ringWidth,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      ringWidth / 2,
      ringWidth / 2,
      size.width - ringWidth,
      size.height - ringWidth,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: colors,
        startAngle: sweepAngle,
        endAngle: sweepAngle + 2 * math.pi,
      ).createShader(rect);

    canvas.drawArc(rect, sweepAngle, 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.sweepAngle != sweepAngle || old.colors != colors;
}
