import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/session_record.dart';
import '../../services/health/health_scorer.dart';
import '../../services/storage_service.dart';
import '../../shared/calm_bg.dart';
import '../../shared/glass_card.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import 'widgets/trend_chart.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  SessionRecord? _today;
  List<SessionRecord>? _week;
  int _score = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = await StorageService.todayRecord();
    final week = await StorageService.recentRecords(7);
    final score = HealthScorer.score(today);
    final streak = HealthScorer.streak(week);
    if (mounted) {
      setState(() {
        _today = today;
        _week = week;
        _score = score;
        _streak = streak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = _today;
    final week = _week;
    final brightness = Theme.of(context).brightness;
    final accent = AppColors.accent(brightness);
    final l10n = AppLocalizations.of(context);

    if (record == null) {
      return CalmBg(
        child: Center(
          child: Text(
            l10n.statsEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary(brightness),
                ),
          ),
        ),
      );
    }

    final weekSeated = week?.map((r) => r.totalSitsMinutes).toList() ?? [];
    final dayLabels = l10n.weekDayLabels;

    return CalmBg(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.screenV + 48,
        ),
        children: [
          // ── Header ──
          Text(l10n.todayTitle,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),

          // ── Health score card ──
          GlassCard(
            child: Row(
              children: [
                // Circular score indicator
                _ScoreRing(score: _score, accent: accent),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.healthScore,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      if (_streak > 0)
                        Text(
                          '$_streak ${l10n.streakDays}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: accent),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // ── Weekly trend ──
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.weeklyTrend,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                TrendChart(
                  seatedMinutes: weekSeated,
                  labels: dayLabels.sublist(
                      0, weekSeated.length.clamp(1, 7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // ── Detailed metrics ──
          GlassCard(
            child: Column(
              children: [
                _StatRow(
                  icon: Icons.self_improvement_outlined,
                  label: l10n.standBreaks,
                  value: '${record.standBreaks}',
                  brightness: brightness,
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatRow(
                  icon: Icons.repeat_outlined,
                  label: l10n.consecutiveSits,
                  value: '${record.standBreaks + 1}',
                  brightness: brightness,
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatRow(
                  icon: Icons.water_drop_outlined,
                  label: l10n.glassesOfWater,
                  value: '${record.hydrationCount}',
                  brightness: brightness,
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatRow(
                  icon: Icons.air_outlined,
                  label: l10n.breathingMinutes,
                  value: '${record.breathingMinutes} ${l10n.minUnit}',
                  brightness: brightness,
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatRow(
                  icon: Icons.access_time_outlined,
                  label: l10n.timeSeated,
                  value: '${record.totalSitsMinutes} ${l10n.minUnit}',
                  brightness: brightness,
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ── Circular score ring ──

class _ScoreRing extends StatelessWidget {
  final int score;
  final Color accent;

  const _ScoreRing({required this.score, required this.accent});

  Color get _color {
    if (score >= 80) return accent;
    if (score >= 50) return Color.lerp(accent, const Color(0xFFC4A67A), 0.5)!;
    return const Color(0xFFC4A67A);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 4,
              color: _color,
              backgroundColor: _color.withValues(alpha: 0.12),
            ),
          ),
          Text(
            '$score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _color,
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Stat row ──

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Brightness brightness;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(brightness);
    return Row(
      children: [
        Icon(icon,
            size: 22, color: accent.withValues(alpha: 0.55)),
        const SizedBox(width: 14),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: accent,
                fontSize: 18,
              ),
        ),
      ],
    );
  }
}
