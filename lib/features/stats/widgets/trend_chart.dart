import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

/// A minimal line chart drawn with CustomPaint.
/// Shows daily seated-minutes trend over the last [records] days.
class TrendChart extends StatelessWidget {
  final List<int> seatedMinutes; // oldest → newest
  final List<String> labels;     // day labels (e.g. "一", "二", ...)

  const TrendChart({
    super.key,
    required this.seatedMinutes,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(Theme.of(context).brightness);
    return SizedBox(
      height: 160,
      child: CustomPaint(
        size: Size.infinite,
        painter: _TrendPainter(
          values: seatedMinutes,
          accent: accent,
          brightness: Theme.of(context).brightness,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(labels.length, (i) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 148),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary(
                            Theme.of(context).brightness),
                      ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<int> values;
  final Color accent;
  final Brightness brightness;

  _TrendPainter({
    required this.values,
    required this.accent,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.reduce(max).toDouble();
    if (maxVal == 0) return;

    // Chart area (leave bottom margin for labels)
    final chartH = size.height - 18;
    final chartW = size.width;
    final stepX = values.length > 1 ? chartW / (values.length - 1) : chartW;

    // Build points
    final points = List.generate(values.length, (i) {
      final x = values.length > 1 ? i * stepX : chartW / 2;
      final y = chartH - (values[i] / maxVal) * chartH;
      return Offset(x, y);
    });

    // ── Fill gradient ──
    final fillPath = Path()..moveTo(points.first.dx, chartH);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, chartH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.20),
          accent.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, chartW, chartH))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // ── Line ──
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final mid = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        (points[i - 1].dy + points[i].dy) / 2,
      );
      linePath.quadraticBezierTo(
          points[i - 1].dx, points[i - 1].dy, mid.dx, mid.dy);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = accent.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // ── Dots ──
    for (final p in points) {
      canvas.drawCircle(p, 3.5, Paint()..color = accent);
      canvas.drawCircle(
        p,
        5.5,
        Paint()
          ..color = accent.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // ── Baseline ──
    canvas.drawLine(
      Offset(0, chartH),
      Offset(chartW, chartH),
      Paint()
        ..color = accent.withValues(alpha: 0.10)
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.values != values || old.accent != accent;
}
