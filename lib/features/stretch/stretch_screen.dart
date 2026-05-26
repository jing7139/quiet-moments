import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/calm_bg.dart';
import '../../theme/colors.dart';

class StretchScreen extends ConsumerWidget {
  const StretchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;

    return CalmBg(
      child: SizedBox.expand(
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.fitness_center_outlined,
              size: 48,
              color: AppColors.accent(brightness).withValues(alpha: 0.45),
            ),
            const SizedBox(height: 24),
            Text(
              'Gentle movements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Simple stretches and mobility exercises\nwill appear here soon.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary(brightness),
                    height: 1.6,
                  ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
