import 'package:flutter/material.dart';

/// Shared type scale (weights/sizing) used by both light and dark themes.
/// Colors are intentionally omitted here — [ColorScheme] supplies those.
class AppTypography {
  const AppTypography._();

  static const TextTheme textTheme = TextTheme(
    headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
    titleLarge: TextStyle(fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(height: 1.4),
    bodyMedium: TextStyle(height: 1.4),
    labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.4),
  );
}
