import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/core/theme/app_theme.dart';

void main() {
  final light = buildAppTheme();
  final dark = buildAppTheme(brightness: Brightness.dark);

  test('defaults to a light Material 3 theme', () {
    expect(light.useMaterial3, isTrue);
    expect(light.colorScheme.brightness, Brightness.light);
  });

  test('builds a dark theme when asked', () {
    expect(dark.useMaterial3, isTrue);
    expect(dark.colorScheme.brightness, Brightness.dark);
  });

  test('uses the same teal accent family in both modes', () {
    expect(light.colorScheme.primary, const Color(0xFF1F6F6B));
    expect(dark.colorScheme.primary, const Color(0xFF6FCBC3));
  });

  test('the page background follows the scheme surface', () {
    expect(light.scaffoldBackgroundColor, light.colorScheme.surface);
    expect(dark.scaffoldBackgroundColor, dark.colorScheme.surface);
    expect(light.scaffoldBackgroundColor, isNot(dark.scaffoldBackgroundColor));
  });

  test('text stays readable against the background in both modes', () {
    for (final theme in [light, dark]) {
      final scheme = theme.colorScheme;
      expect(scheme.onSurface, isNot(scheme.surface));
      // Contrast ratio of at least 4.5:1, the WCAG AA minimum for body text.
      expect(_contrast(scheme.onSurface, scheme.surface), greaterThan(4.5));
      expect(_contrast(scheme.onPrimary, scheme.primary), greaterThan(4.5));
    }
  });

  test('the app bar is plain, left aligned and flat', () {
    for (final theme in [light, dark]) {
      expect(theme.appBarTheme.centerTitle, isFalse);
      expect(theme.appBarTheme.backgroundColor, theme.colorScheme.surface);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
    }
  });

  test('selected chips use the accent colour', () {
    expect(light.chipTheme.selectedColor, light.colorScheme.primary);
    expect(dark.chipTheme.selectedColor, dark.colorScheme.primary);
  });

  test('the search field is filled and rounded', () {
    final decoration = light.inputDecorationTheme;
    expect(decoration.filled, isTrue);
    expect(decoration.border, isA<OutlineInputBorder>());
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
