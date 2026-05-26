import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/calm_bg.dart';
import '../../theme/colors.dart';

class StretchScreen extends ConsumerWidget {
  const StretchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);

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
              l10n.gentleMovements,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.stretchSoon,
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
