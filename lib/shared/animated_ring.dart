import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A softly animated ring — used for breathing exercises and timer states.
///
/// The ring pulses gently at [frequency] cycles per [period].
class AnimatedRing extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? child;

  /// How far the ring "breathes" — fraction of [size].
  final double amplitude;

  /// Duration of one full breathe cycle.
  final Duration period;

  const AnimatedRing({
    super.key,
    this.size = 200,
    this.strokeWidth = 2.5,
    this.color,
    this.child,
    this.amplitude = 0.06,
    this.period = const Duration(milliseconds: 4000),
  });

  @override
  State<AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<AnimatedRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ringColor = widget.color ?? AppColors.accent(brightness);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final scale =
            1.0 + sin(_ctrl.value * 2 * pi) * widget.amplitude;

        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RingPainter(
            color: ringColor,
            strokeWidth: widget.strokeWidth,
            progress: 1.0,
            opacity: 0.3 + _ctrl.value * 0.25,
          ),
          child: Center(
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double progress;
  final double opacity;

  _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Full ring arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );

    // Outer glow ring
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      color != old.color ||
      strokeWidth != old.strokeWidth ||
      progress != old.progress ||
      opacity != old.opacity;
}
