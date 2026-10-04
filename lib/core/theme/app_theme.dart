import 'package:flutter/material.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;

  // Warm neutrals with a single teal accent.
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F6F6B),
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFF6FCBC3) : const Color(0xFF1F6F6B),
        onPrimary: dark ? const Color(0xFF00201E) : Colors.white,
        surface: dark ? const Color(0xFF161614) : const Color(0xFFFAF8F5),
        onSurface: dark ? const Color(0xFFEDEAE4) : const Color(0xFF1C1B1A),
        onSurfaceVariant: dark
            ? const Color(0xFFA9A59D)
            : const Color(0xFF6B675F),
        outlineVariant: dark
            ? const Color(0xFF3A3834)
            : const Color(0xFFE3DED5),
        surfaceContainerLow: dark ? const Color(0xFF1E1D1A) : Colors.white,
        surfaceContainerHighest: dark
            ? const Color(0xFF2A2926)
            : const Color(0xFFEFEBE3),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: scheme.primary,
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: scheme.onSurface),
      secondaryLabelStyle: TextStyle(
        color: scheme.onPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
