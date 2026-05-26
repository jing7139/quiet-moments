import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/calm_bg.dart';
import '../../theme/colors.dart';
import 'sedentary_provider.dart';
import 'widgets/timer_ring.dart';

class SedentaryScreen extends ConsumerWidget {
  const SedentaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sedentaryProvider);
    final notifier = ref.read(sedentaryProvider.notifier);
    final brightness = Theme.of(context).brightness;

    return CalmBg(
      child: SizedBox.expand(
        child: Column(
          children: [
            const Spacer(flex: 5),

            // ── Timer ring ──
            _TactileWrapper(
              child: TimerRing(
                size: 260,
                progress: state.progress,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      key: ValueKey(state.elapsedMinutes),
                      tween: Tween(begin: 0.96, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Text(
                        '${state.elapsedMinutes}',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'minutes seated',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 2),

            // ── Message ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Text(
                state.message,
                key: ValueKey(state.message),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary(brightness),
                      height: 1.6,
                    ),
              ),
            ),

            // ── Reset button (visible when user has been sitting a while) ──
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: state.elapsedMinutes >= 2 ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _ResetButton(onTap: () => notifier.reset()),
              ),
            ),

            const Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}

/// A whisper-soft reset button. Just text, no container.
class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ResetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: Text(
        'I stood up',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.accent(brightness).withValues(alpha: 0.70),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

/// Wraps a widget with a soft tactile tap response.
class _TactileWrapper extends StatefulWidget {
  final Widget child;
  const _TactileWrapper({required this.child});

  @override
  State<_TactileWrapper> createState() => _TactileWrapperState();
}

class _TactileWrapperState extends State<_TactileWrapper> {
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _tapCount++),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_tapCount),
        tween: Tween(begin: 0.965, end: 1.0),
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
        builder: (_, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: widget.child,
      ),
    );
  }
}
