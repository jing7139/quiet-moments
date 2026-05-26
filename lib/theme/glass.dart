import 'dart:ui';
import 'package:flutter/material.dart';
import 'spacing.dart';

/// Predefined glass effect levels.
enum GlassLevel {
  /// Subtle card background.
  card,

  /// Medium blur, for modals and bottom sheets.
  sheet,

  /// Heavy frost, for overlays and dialogs.
  overlay,
}

/// Resolves glass effect parameters for the current theme brightness.
///
/// Use [GlassSpec.of] to get the right [GlassSpec] for a given level.
class GlassSpec {
  final Color backgroundColor;
  final double blur;
  final BorderRadius borderRadius;

  const GlassSpec({
    required this.backgroundColor,
    required this.blur,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppSpacing.radiusLg),
    ),
  });

  ImageFilter get filter => ImageFilter.blur(sigmaX: blur, sigmaY: blur);

  factory GlassSpec.of(BuildContext context, GlassLevel level) {
    final brightness = Theme.of(context).brightness;
    switch (level) {
      case GlassLevel.card:
        return brightness == Brightness.light
            ? const GlassSpec(
                backgroundColor: Color(0x99FFFFFF), // 60%
                blur: 8,
              )
            : const GlassSpec(
                backgroundColor: Color(0x1AFFFFFF), // 10%
                blur: 10,
              );
      case GlassLevel.sheet:
        return brightness == Brightness.light
            ? const GlassSpec(
                backgroundColor: Color(0xCCFFFFFF), // 80%
                blur: 16,
              )
            : const GlassSpec(
                backgroundColor: Color(0x29FFFFFF), // 16%
                blur: 20,
              );
      case GlassLevel.overlay:
        return brightness == Brightness.light
            ? const GlassSpec(
                backgroundColor: Color(0xEBFFFFFF), // 92%
                blur: 24,
              )
            : const GlassSpec(
                backgroundColor: Color(0x3DFFFFFF), // 24%
                blur: 28,
              );
    }
  }
}
