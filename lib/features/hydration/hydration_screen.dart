import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/calm_bg.dart';
import '../../theme/colors.dart';
import 'hydration_provider.dart';

class HydrationScreen extends ConsumerWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hydrationProvider);
    final notifier = ref.read(hydrationProvider.notifier);
    final brightness = Theme.of(context).brightness;

    return CalmBg(
      child: SizedBox.expand(
        child: Column(
          children: [
            const Spacer(flex: 4),

            // Glass counter
            _WaterGlasses(
              count: state.glassesToday,
              goal: state.dailyGoal,
            ),

            const SizedBox(height: 12),
            Text(
              '${state.glassesToday} of ${state.dailyGoal}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const Spacer(),

            // Add button
            GestureDetector(
              onTap: () => notifier.addGlass(),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent(brightness).withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.accent(brightness).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 28,
                  color: AppColors.accent(brightness).withValues(alpha: 0.80),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Tap to log a glass',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
            ),

            // Undo
            if (state.glassesToday > 0)
              TextButton(
                onPressed: () => notifier.removeGlass(),
                child: Text(
                  'Undo',
                  style: TextStyle(
                    color: AppColors.textSecondary(brightness),
                    fontSize: 13,
                  ),
                ),
              ),

            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}

/// Draws a row of glass icons — filled and unfilled.
class _WaterGlasses extends StatelessWidget {
  final int count;
  final int goal;

  const _WaterGlasses({required this.count, required this.goal});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final accent = AppColors.accent(brightness);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(goal, (i) {
        final filled = i < count;
        return Icon(
          filled ? Icons.water_drop : Icons.water_drop_outlined,
          size: 28,
          color: filled
              ? accent.withValues(alpha: 0.85)
              : AppColors.divider(brightness),
        );
      }),
    );
  }
}
