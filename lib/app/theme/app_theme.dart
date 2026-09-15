import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF6750F4);

  static final ThemeData light = _build(
    ColorScheme.fromSeed(seedColor: _seedColor),
  );

  static final ThemeData dark = _build(
    ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark),
  );

  static ThemeData _build(ColorScheme colors) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: colors.surfaceContainer,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return base.textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.onSurface
                : colors.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surfaceContainer,
        indicatorColor: colors.primaryContainer,
        selectedIconTheme: IconThemeData(color: colors.onPrimaryContainer),
        selectedLabelTextStyle: base.textTheme.labelLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
