class ApiConfig {
  static const host = 'api.themoviedb.org';
  static const _imageBaseUrl = 'https://image.tmdb.org/t/p';

  /// [size] is a TMDB image width such as w185 or w500.
  static String imageUrl(String path, {String size = 'w185'}) =>
      '$_imageBaseUrl/$size$path';

  // Passed at build time: --dart-define-from-file=env.json (see README).
  static const apiKey = String.fromEnvironment('TMDB_API_KEY');
}
