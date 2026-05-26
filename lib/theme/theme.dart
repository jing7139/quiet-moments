import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,

      scaffoldBackgroundColor: AppColors.bg(brightness),

      colorSchemeSeed: AppColors.accent(brightness),

      textTheme: TextTheme(
        displayLarge: AppText.display(brightness),
        titleLarge: AppText.title(brightness),
        bodyLarge: AppText.body(brightness),
        bodyMedium: AppText.caption(brightness),
        labelLarge: AppText.button(brightness),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppText.title(brightness),
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface(brightness),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.zero,
      ),

      // Softer bottom nav — nearly transparent, subtle indicator.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.accent(brightness).withValues(alpha: 0.14),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          AppText.caption(brightness).copyWith(fontSize: 11),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(
            size: 22,
            color: AppColors.textSecondary(brightness),
          ),
        ),
        height: 64,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.divider(brightness),
        thickness: 0.5,
        space: 0,
      ),

      splashFactory: isLight ? NoSplash.splashFactory : InkRipple.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
