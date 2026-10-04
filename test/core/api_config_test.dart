import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/core/config/api_config.dart';

void main() {
  test('builds image urls with the default size', () {
    expect(
      ApiConfig.imageUrl('/poster.jpg'),
      'https://image.tmdb.org/t/p/w185/poster.jpg',
    );
  });

  test('builds image urls with a given size', () {
    expect(
      ApiConfig.imageUrl('/back.jpg', size: 'w780'),
      'https://image.tmdb.org/t/p/w780/back.jpg',
    );
  });

  test('talks to the TMDB host', () {
    expect(ApiConfig.host, 'api.themoviedb.org');
  });

  test('has no API key unless one is passed with --dart-define-from-file', () {
    // Keeps the key out of the source. If this ever fails, a key got committed.
    expect(ApiConfig.apiKey, isEmpty);
  });
}
