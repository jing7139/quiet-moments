import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/calm_bg.dart';
import '../../theme/colors.dart';
import 'breathing_provider.dart';

class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animCtrl;

  static const _cycleDuration = Duration(milliseconds: 16000); // 4-4-4-4
  static const _minScale = 0.72;
  static const _maxScale = 1.0;

  @override
  void dispose() {
    _animCtrl?.dispose();
    super.dispose();
  }

  void _start() {
    ref.read(breathingProvider.notifier).start();
    _animCtrl = AnimationController(
      vsync: this,
      duration: _cycleDuration,
    );
    _animCtrl!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ref.read(breathingProvider.notifier).onCycleComplete();
        _animCtrl?.repeat();
      }
    });
    _animCtrl!.repeat();
  }

  void _stop() {
    ref.read(breathingProvider.notifier).stop();
    _animCtrl?.stop();
    _animCtrl?.dispose();
    _animCtrl = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breathingProvider);
    final brightness = Theme.of(context).brightness;
    final accent = AppColors.accent(brightness);
    final l10n = AppLocalizations.of(context);

    final ringScale = _animCtrl != null && _animCtrl!.isAnimating
        ? _computeScale(_animCtrl!.value)
        : _minScale;

    final phaseLabel = _animCtrl != null && _animCtrl!.isAnimating
        ? _phaseLabel(_animCtrl!.value, l10n)
        : '';

    return CalmBg(
      child: SizedBox.expand(
        child: Column(
          children: [
            const Spacer(flex: 3),

            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: _TrackPainter(accent),
                  ),
                  AnimatedBuilder(
                    animation:
                        _animCtrl ?? AnimationController(vsync: this),
                    builder: (_, __) {
                      final s = _animCtrl?.isAnimating == true
                          ? _computeScale(_animCtrl!.value)
                          : _minScale;
                      return Transform.scale(
                        scale: s,
                        child: CustomPaint(
                          size: const Size(200, 200),
                          painter: _BreathingRingPainter(accent, s),
                        ),
                      );
                    },
                  ),
                  if (state.isRunning)
                    Text(
                      phaseLabel,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: accent),
                    )
                  else
                    Text(
                      l10n.breatheIdle,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: AppColors.textSecondary(brightness),
                          ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            if (state.isRunning || state.cyclesCompleted > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  state.isRunning
                      ? '${state.cyclesCompleted + 1} ${l10n.breathingCycles}'
                      : '${state.cyclesCompleted} ${l10n.breathingCycles} · ${_fmtDuration(state.sessionSeconds)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            GestureDetector(
              onTap: state.isRunning ? _stop : _start,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: state.isRunning ? 0.10 : 0.18),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: Icon(
                  state.isRunning ? Icons.stop : Icons.play_arrow,
                  size: 26,
                  color: accent.withValues(alpha: 0.80),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              state.isRunning ? l10n.stopBtn : l10n.startBtn,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
            ),

            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }

  double _computeScale(double t) {
    if (t < 0.25) {
      return _minScale +
          (_maxScale - _minScale) * Curves.easeInOut.transform(t / 0.25);
    } else if (t < 0.5) {
      return _maxScale;
    } else if (t < 0.75) {
      return _maxScale -
          (_maxScale - _minScale) *
              Curves.easeInOut.transform((t - 0.5) / 0.25);
    } else {
      return _minScale;
    }
  }

  String _phaseLabel(double t, AppLocalizations l10n) {
    if (t < 0.25) return l10n.breatheIn;
    if (t < 0.5) return l10n.breatheHold;
    if (t < 0.75) return l10n.breatheOut;
    return l10n.breatheHold;
  }

  String _fmtDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _TrackPainter extends CustomPainter {
  final Color color;
  _TrackPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 6,
      paint,
    );
  }

  @override
  bool shouldRepaint(_TrackPainter old) => color != old.color;
}

class _BreathingRingPainter extends CustomPainter {
  final Color color;
  final double scale;
  _BreathingRingPainter(this.color, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = 0.25 + scale * 0.55;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 10,
      paint,
    );

    final glow = Paint()
      ..color = color.withValues(alpha: opacity * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 10,
      glow,
    );
  }

  @override
  bool shouldRepaint(_BreathingRingPainter old) =>
      color != old.color || scale != old.scale;
}
