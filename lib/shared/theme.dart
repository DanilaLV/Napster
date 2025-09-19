import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF1E5AFF),
      secondary: const Color(0xFF00BFA5),
      surface: const Color(0xFFF4F6FB),
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F6FB),
    textTheme: base.textTheme.apply(
      fontFamily: 'Roboto',
      bodyColor: const Color(0xFF1A1C1E),
      displayColor: const Color(0xFF1A1C1E),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1A1C1E),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
    useMaterial3: true,
  );
}
