import 'package:flutter/material.dart';

/// A full-screen gradient background that adapts to brightness.
///
/// Light: warm cream → soft linen.
/// Dark:  deep charcoal with a hint of warmth.
class CalmBg extends StatelessWidget {
  final Widget child;

  const CalmBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: brightness == Brightness.light
              ? const [Color(0xFFF3F1ED), Color(0xFFEBE7E1)]
              : const [Color(0xFF151B1A), Color(0xFF1A2120)],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
