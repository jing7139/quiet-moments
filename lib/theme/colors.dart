import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ── Light palette (warm, paper-like) ──
  static const lightBg = Color(0xFFF3F1ED);
  static const lightSurface = Color(0x99FFFFFF); // 60%
  static const lightSurface2 = Color(0xCCFFFFFF); // 80%
  static const lightTextPrimary = Color(0xFF1F1C1A);
  static const lightTextSecondary = Color(0xFF7A7268);
  static const lightAccent = Color(0xFF8B9E9C);
  static const lightDivider = Color(0x121F1C1A); // 7%
  static const lightSuccess = Color(0xFF7DA08A);
  static const lightWarning = Color(0xFFC9AA7A);

  // ── Dark palette (warm deep tones) ──
  static const darkBg = Color(0xFF151B1A);
  static const darkSurface = Color(0x14FFFFFF); // 8%
  static const darkSurface2 = Color(0x24FFFFFF); // 14%
  static const darkTextPrimary = Color(0xFFEDEFEE);
  static const darkTextSecondary = Color(0xFF96A09D);
  static const darkAccent = Color(0xFF9BB5B8);
  static const darkDivider = Color(0x14FFFFFF); // 8%
  static const darkSuccess = Color(0xFF8BB99A);
  static const darkWarning = Color(0xFFD4BA84);

  // ── Resolve by brightness ──
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

  static Color divider(Brightness b) =>
      b == Brightness.light ? lightDivider : darkDivider;

  static Color success(Brightness b) =>
      b == Brightness.light ? lightSuccess : darkSuccess;

  static Color warning(Brightness b) =>
      b == Brightness.light ? lightWarning : darkWarning;

  static Color accentGlow(Brightness b) =>
      accent(b).withValues(alpha: 0.18);
}
