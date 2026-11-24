import 'package:flutter/material.dart';

abstract final class AeroColors {
  static const navy = Color(0xFF15224B);
  static const navySoft = Color(0xFF263665);
  static const cyan = Color(0xFF4169FF);
  static const blue = Color(0xFF3157F5);
  static const coral = Color(0xFFFF6685);
  static const emerald = Color(0xFF17B890);
  static const ice = Color(0xFFF5F7FC);
  static const line = Color(0xFFDDE3F1);
  static const ink = Color(0xFF19223A);
  static const muted = Color(0xFF6F7890);
}

abstract final class AeroTechTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AeroColors.cyan,
      brightness: Brightness.light,
      primary: AeroColors.navy,
      secondary: AeroColors.cyan,
      error: AeroColors.coral,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AeroColors.ice,
      fontFamily: 'SpaceGrotesk',
      appBarTheme: const AppBarTheme(
        backgroundColor: AeroColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AeroColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AeroColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AeroColors.cyan, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AeroColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AeroColors.line),
        ),
      ),
    );
  }
}
