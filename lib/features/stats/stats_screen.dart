import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session_record.dart';
import '../../services/storage_service.dart';
import '../../shared/calm_bg.dart';
import '../../theme/colors.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  SessionRecord? _today;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final record = await StorageService.todayRecord();
    if (mounted) setState(() => _today = record);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final record = _today;

    return CalmBg(
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                'Today',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 40),
              if (record != null) ...[
                _StatRow(
                  icon: Icons.self_improvement_outlined,
                  label: 'Stand breaks',
                  value: '${record.standBreaks}',
                  brightness: brightness,
                ),
                const SizedBox(height: 24),
                _StatRow(
                  icon: Icons.water_drop_outlined,
                  label: 'Glasses of water',
                  value: '${record.hydrationCount}',
                  brightness: brightness,
                ),
                const SizedBox(height: 24),
                _StatRow(
                  icon: Icons.air_outlined,
                  label: 'Breathing minutes',
                  value: '${record.breathingMinutes}',
                  brightness: brightness,
                ),
                const SizedBox(height: 24),
                _StatRow(
                  icon: Icons.access_time_outlined,
                  label: 'Time seated',
                  value: '${record.totalSitsMinutes} min',
                  brightness: brightness,
                ),
              ] else
                Text(
                  'Your wellness summary\nwill appear here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary(brightness),
                        height: 1.6,
                      ),
                ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.accent(brightness).withValues(alpha: 0.55)),
        const SizedBox(width: 14),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.accent(brightness),
              ),
        ),
      ],
    );
  }
}
