import 'package:flutter/material.dart';

class AmbientGlow extends StatefulWidget {
  final Color color;
  final Duration duration;

  const AmbientGlow({
    super.key,
    required this.color,
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<AmbientGlow> createState() => _AmbientGlowState();
}

class _AmbientGlowState extends State<AmbientGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
      child: IgnorePointer(
        child: Container(
          width: 600,
          height: 600,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withOpacity(0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.7],
            ),
          ),
        ),
      ),
    );
  }
}
