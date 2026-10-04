import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/core/format/release_date.dart';

void main() {
  test('formats an ISO date', () {
    expect(formatReleaseDate('2024-02-27'), 'Feb 27, 2024');
    expect(formatReleaseDate('2026-12-01'), 'Dec 1, 2026');
  });

  test('handles a leap day', () {
    expect(formatReleaseDate('2024-02-29'), 'Feb 29, 2024');
  });

  test('returns null for missing or blank values', () {
    expect(formatReleaseDate(null), isNull);
    expect(formatReleaseDate(''), isNull);
    expect(formatReleaseDate('   '), isNull);
  });

  test('leaves partial or non-date values alone', () {
    expect(formatReleaseDate('2024'), '2024');
    expect(formatReleaseDate('2024-02'), '2024-02');
    expect(formatReleaseDate('TBA'), 'TBA');
  });

  test('does not roll an impossible date over to the next month', () {
    expect(formatReleaseDate('2024-02-31'), '2024-02-31');
    expect(formatReleaseDate('2023-02-29'), '2023-02-29');
    expect(formatReleaseDate('2024-13-01'), '2024-13-01');
  });

  test('trims surrounding whitespace', () {
    expect(formatReleaseDate(' 2024-02-27 '), 'Feb 27, 2024');
  });
}
