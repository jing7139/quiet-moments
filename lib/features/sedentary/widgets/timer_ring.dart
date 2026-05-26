import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

/// A progress ring that breathes at a resting-human rhythm (~8.5 bpm).
class TimerRing extends StatefulWidget {
  final double size;
  final double progress; // 0.0 → 1.0
  final Widget? child;

  const TimerRing({
    super.key,
    required this.size,
    required this.progress,
    this.child,
  });

  @override
  State<TimerRing> createState() => _TimerRingState();
}

class _TimerRingState extends State<TimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000), // ~8.5 bpm — resting breath
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final accent = AppColors.accent(brightness);

    return AnimatedBuilder(
      animation: _ambient,
      builder: (_, child) {
        final breathe = 1.0 + sin(_ambient.value * 2 * pi) * 0.016;

        return Transform.scale(
          scale: breathe,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _TimerRingPainter(
              color: accent,
              progress: widget.progress.clamp(0.0, 1.0),
            ),
            child: Center(child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final Color color;
  final double progress;

  _TimerRingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    // Track
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

    // Progress arc
    final arcPaint = Paint()
      ..color = color.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    // Head dot
    if (progress > 0.01) {
      final headAngle = startAngle + sweepAngle;
      final headX = center.dx + radius * cos(headAngle);
      final headY = center.dy + radius * sin(headAngle);

      final dotPaint = Paint()
        ..color = color.withValues(alpha: 0.50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(Offset(headX, headY), 5.0, dotPaint);

      final corePaint = Paint()..color = color.withValues(alpha: 0.88);
      canvas.drawCircle(Offset(headX, headY), 2.5, corePaint);
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter old) =>
      color != old.color || progress != old.progress;
}
