import 'package:flutter/material.dart';
import '../theme/spacing.dart';

/// A soft, rounded button with subtle glass styling.
class GlassButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final IconData? icon;
  final bool primary;

  const GlassButton({
    super.key,
    this.onTap,
    required this.label,
    this.icon,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: primary
              ? colors.primary.withValues(alpha: 0.18)
              : colors.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: colors.onSurface),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
