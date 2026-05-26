import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/notification_service.dart';
import '../../shared/calm_bg.dart';
import '../../shared/glass_card.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return CalmBg(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.screenV + 48,
        ),
        children: [
          // ── Header ──
          Text(
            l10n.settingsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.settingsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(
                      Theme.of(context).brightness),
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Sedentary interval ──
          GlassCard(
            child: _SliderSetting(
              label: l10n.sedentaryLabel,
              value: config.sedentaryIntervalMinutes,
              suffixLabel: l10n.minutesValue(config.sedentaryIntervalMinutes),
              min: 15,
              max: 120,
              divisions: 21,
              onChanged: (v) => notifier.setSedentaryInterval(v.round()),
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // ── Hydration interval ──
          GlassCard(
            child: _SliderSetting(
              label: l10n.hydrationLabel,
              value: config.hydrationIntervalMinutes,
              suffixLabel: l10n.minutesValue(config.hydrationIntervalMinutes),
              min: 30,
              max: 120,
              divisions: 18,
              onChanged: (v) => notifier.setHydrationInterval(v.round()),
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // ── Quiet mode ──
          GlassCard(
            child: _ToggleSetting(
              label: l10n.quietModeLabel,
              value: config.quietMode,
              onChanged: (v) => notifier.setQuietMode(v),
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // ── Quiet hours ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: config.quietMode
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: l10n.quietStartLabel,
                      time: config.quietStart,
                      onChanged: (t) => notifier.setQuietStart(t),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TimePicker(
                      label: l10n.quietEndLabel,
                      time: config.quietEnd,
                      onChanged: (t) => notifier.setQuietEnd(t),
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // ── Notification preferences ──
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.notifTitle,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                _ToggleSetting(
                  label: l10n.normalSoundLabel,
                  value: config.normalSound,
                  onChanged: (v) {
                    notifier.setNormalSound(v);
                    NotificationService.updateSoundPrefs(
                      normalSound: v,
                      normalVibrate: config.normalVibrate,
                      urgentSound: config.urgentSound,
                      urgentVibrate: config.urgentVibrate,
                    );
                  },
                ),
                _ToggleSetting(
                  label: l10n.normalVibrateLabel,
                  value: config.normalVibrate,
                  onChanged: (v) {
                    notifier.setNormalVibrate(v);
                    NotificationService.updateSoundPrefs(
                      normalSound: config.normalSound,
                      normalVibrate: v,
                      urgentSound: config.urgentSound,
                      urgentVibrate: config.urgentVibrate,
                    );
                  },
                ),
                _ToggleSetting(
                  label: l10n.urgentSoundLabel,
                  value: config.urgentSound,
                  onChanged: (v) {
                    notifier.setUrgentSound(v);
                    NotificationService.updateSoundPrefs(
                      normalSound: config.normalSound,
                      normalVibrate: config.normalVibrate,
                      urgentSound: v,
                      urgentVibrate: config.urgentVibrate,
                    );
                  },
                ),
                _ToggleSetting(
                  label: l10n.urgentVibrateLabel,
                  value: config.urgentVibrate,
                  onChanged: (v) {
                    notifier.setUrgentVibrate(v);
                    NotificationService.updateSoundPrefs(
                      normalSound: config.normalSound,
                      normalVibrate: config.normalVibrate,
                      urgentSound: config.urgentSound,
                      urgentVibrate: v,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
          Text(
            l10n.settingsNote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(
                          Theme.of(context).brightness)
                      .withValues(alpha: 0.6),
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ── Slider row ──

class _SliderSetting extends StatelessWidget {
  final String label;
  final int value;
  final String suffixLabel;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.label,
    required this.value,
    required this.suffixLabel,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label,
                style: Theme.of(context).textTheme.bodyLarge)),
            Text(suffixLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: accent,
                      fontSize: 18,
                    )),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accent.withValues(alpha: 0.6),
            inactiveTrackColor: accent.withValues(alpha: 0.12),
            thumbColor: accent,
            overlayColor: accent.withValues(alpha: 0.08),
            trackHeight: 3,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ── Toggle row ──

class _ToggleSetting extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(Theme.of(context).brightness);
    return Row(
      children: [
        Expanded(child: Text(label,
            style: Theme.of(context).textTheme.bodyLarge)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accent,
        ),
      ],
    );
  }
}

// ── Time picker ──

class _TimePicker extends StatelessWidget {
  final String label;
  final String time;
  final ValueChanged<String> onChanged;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(Theme.of(context).brightness);

    return GestureDetector(
      onTap: () => _pickTime(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                  color: accent.withValues(alpha: 0.15), width: 1),
              color: accent.withValues(alpha: 0.05),
            ),
            child: Text(time,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: accent,
                    )),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final parts = time.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 22,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      onChanged('$h:$m');
    }
  }
}
