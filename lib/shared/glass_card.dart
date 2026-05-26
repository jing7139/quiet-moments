import 'package:flutter/material.dart';
import '../theme/glass.dart';
import '../theme/spacing.dart';

/// A translucent card with soft rounded corners and blur.
class GlassCard extends StatelessWidget {
  final Widget child;
  final GlassLevel level;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.level = GlassLevel.card,
    this.padding = const EdgeInsets.all(AppSpacing.cardInner),
    this.borderRadius,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final spec = GlassSpec.of(context, level);

    return ClipRRect(
      borderRadius: borderRadius ?? spec.borderRadius,
      child: BackdropFilter(
        filter: spec.filter,
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: spec.backgroundColor,
            borderRadius: borderRadius ?? spec.borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
