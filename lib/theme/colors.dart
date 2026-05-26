import 'package:flutter/material.dart';

/// Forest + Apple Health hybrid palette.
///
/// Keywords: 留白  柔和  自然  高级感  轻玻璃感  卡片化
///
/// Light mode → "forest morning" — cream white bg, forest green accent.
/// Dark mode  → "deep forest night" — deep green-black bg, light sage accent.
class AppColors {
  const AppColors._();

  // ── Light palette ──
  static const lightBg = Color(0xFFF7F8F4);          // forest cream
  static const lightSurface = Color(0x99FFFFFF);      // 60% white glass
  static const lightSurface2 = Color(0xCCFFFFFF);     // 80% white glass
  static const lightTextPrimary = Color(0xFF1B2520);   // deep pine ink
  static const lightTextSecondary = Color(0xFF7D8B83); // sage gray
  static const lightAccent = Color(0xFF6B9080);        // forest green
  static const lightSecondary = Color(0xFFA0B5B8);     // fog blue
  static const lightDivider = Color(0x121B2520);
  static const lightSuccess = Color(0xFF7DAC8A);       // moss green
  static const lightWarning = Color(0xFFC4A67A);       // soft amber

  // ── Dark palette ──
  static const darkBg = Color(0xFF19231F);            // deep forest
  static const darkSurface = Color(0x14FFFFFF);
  static const darkSurface2 = Color(0x24FFFFFF);
  static const darkTextPrimary = Color(0xFFE6EDE9);    // pale mint
  static const darkTextSecondary = Color(0xFF8A9B92);  // muted forest gray
  static const darkAccent = Color(0xFF8DB5A5);         // light sage
  static const darkSecondary = Color(0xFF9BB5B8);      // fog blue
  static const darkDivider = Color(0x14FFFFFF);
  static const darkSuccess = Color(0xFF8EBB96);        // light moss
  static const darkWarning = Color(0xFFCEB588);        // light amber

  // ── Resolvers ──

  static Color bg(Brightness b) =>
      b == Brightness.light ? lightBg : darkBg;

  static Color surface(Brightness b) =>
      b == Brightness.light ? lightSurface : darkSurface;

  static Color surface2(Brightness b) =>
      b == Brightness.light ? lightSurface2 : darkSurface2;

  static Color textPrimary(Brightness b) =>
      b == Brightness.light ? lightTextPrimary : darkTextPrimary;

  static Color textSecondary(Brightness b) =>
      b == Brightness.light ? lightTextSecondary : darkTextSecondary;

  static Color accent(Brightness b) =>
      b == Brightness.light ? lightAccent : darkAccent;

  static Color secondary(Brightness b) =>
      b == Brightness.light ? lightSecondary : darkSecondary;

  static Color divider(Brightness b) =>
      b == Brightness.light ? lightDivider : darkDivider;

  static Color success(Brightness b) =>
      b == Brightness.light ? lightSuccess : darkSuccess;

  static Color warning(Brightness b) =>
      b == Brightness.light ? lightWarning : darkWarning;

  static Color accentGlow(Brightness b) =>
      accent(b).withValues(alpha: 0.18);
}
