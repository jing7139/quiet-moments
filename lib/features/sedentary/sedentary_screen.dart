import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/session_record.dart';
import '../../services/health/health_engine.dart';
import '../../services/storage_service.dart';
import '../../shared/calm_bg.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import 'sedentary_provider.dart';
import 'widgets/timer_ring.dart';

class SedentaryScreen extends ConsumerWidget {
  const SedentaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sedentaryProvider);
    final notifier = ref.read(sedentaryProvider.notifier);
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);

    return CalmBg(
      child: Stack(
        children: [
          SizedBox.expand(
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
                      l10n.minutesSeated,
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
                l10n.sitMessage(state.progress, state.elapsedSeconds),
                key: ValueKey(l10n.sitMessage(state.progress, state.elapsedSeconds)),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary(brightness),
                      height: 1.6,
                    ),
              ),
            ),

            // ── Reset button ──
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: state.elapsedMinutes >= 2 ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _ResetButton(
                  onTap: () => notifier.reset(),
                  label: l10n.iStoodUp,
                ),
              ),
            ),

            // ── Health suggestions ──
            const _Suggestions(),

            const Spacer(flex: 5),
          ],
        ),
      ),
      // ── Settings gear ──
      Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        right: 12,
        child: IconButton(
          icon: const Icon(Icons.settings_outlined, size: 20),
          color: AppColors.textSecondary(brightness).withValues(alpha: 0.5),
          onPressed: () => context.push('/settings'),
        ),
      ),
    ]),
    );
  }
}

class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const _ResetButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.accent(brightness).withValues(alpha: 0.70),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

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

/// Loads recent wellness data and shows up to 2 suggestions from the engine.
class _Suggestions extends StatefulWidget {
  const _Suggestions();

  @override
  State<_Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<_Suggestions> {
  List<Suggestion>? _suggestions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = await StorageService.todayRecord();
    final history = await StorageService.recentRecords(14);
    // Remove today from history (last element is today).
    if (history.isNotEmpty) history.removeLast();

    final locale = AppLocalizations.resolvedLocale;
    final engine = const RuleHealthEngine();
    final suggestions = engine.analyze(history, today, locale: locale);

    if (mounted) setState(() => _suggestions = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    final list = _suggestions;
    if (list == null || list.isEmpty) return const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    final accent = AppColors.accent(brightness);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          for (final s in list)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    s.kind == SuggestionKind.positive
                        ? Icons.light_mode_outlined
                        : s.kind == SuggestionKind.nudge
                            ? Icons.auto_awesome_outlined
                            : Icons.circle_outlined,
                    size: 14,
                    color: accent.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary(brightness)
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
