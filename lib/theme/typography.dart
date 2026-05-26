import 'package:flutter/material.dart';
import 'colors.dart';

class AppText {
  const AppText._();

  static const _family = null; // system font

  static TextStyle display(Brightness b) => TextStyle(
        fontFamily: _family,
        fontSize: 38,
        fontWeight: FontWeight.w300,
        height: 1.12,
        letterSpacing: -0.8,
        color: AppColors.textPrimary(b),
      );

  static TextStyle title(Brightness b) => TextStyle(
        fontFamily: _family,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: -0.3,
        color: AppColors.textPrimary(b),
      );

  static TextStyle body(Brightness b) => TextStyle(
        fontFamily: _family,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.textPrimary(b),
      );

  static TextStyle caption(Brightness b) => TextStyle(
        fontFamily: _family,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
        letterSpacing: 0.2,
        color: AppColors.textSecondary(b),
      );

  static TextStyle button(Brightness b) => TextStyle(
        fontFamily: _family,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.20,
        letterSpacing: 0.3,
        color: AppColors.textPrimary(b),
      );
}
