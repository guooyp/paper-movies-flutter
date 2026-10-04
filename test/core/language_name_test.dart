import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/core/format/language_name.dart';
import 'package:paper_movies/features/movies/domain/entities/genre.dart';

void main() {
  group('languageName', () {
    test('translates known codes, ignoring case and spaces', () {
      expect(languageName('en'), 'English');
      expect(languageName(' JA '), 'Japanese');
    });

    test('upper-cases codes it does not know', () {
      expect(languageName('sv'), 'SV');
    });

    test('returns null when missing', () {
      expect(languageName(null), isNull);
      expect(languageName('  '), isNull);
    });
  });

  group('genreNames', () {
    test('maps known ids in order', () {
      expect(genreNames([28, 878, 12]), [
        'Action',
        'Science Fiction',
        'Adventure',
      ]);
    });

    test('drops ids it does not know', () {
      expect(genreNames([28, 999999]), ['Action']);
      expect(genreNames(const []), isEmpty);
    });
  });
}
