import '../../domain/entities/movie.dart';

class MovieModel {
  const MovieModel({
    required this.id,
    required this.title,
    required this.voteAverage,
    this.posterPath,
    this.releaseDate,
    this.overview,
    this.backdropPath,
    this.voteCount = 0,
    this.originalLanguage,
    this.genreIds = const [],
  });

  /// Only `id` is required. Everything else falls back to something sensible,
  /// since TMDB sends null or empty strings for some fields.
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title:
          _firstNonBlank([json['title'], json['original_title']]) ?? 'Untitled',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      posterPath: _firstNonBlank([json['poster_path']]),
      releaseDate: _firstNonBlank([json['release_date']]),
      overview: _firstNonBlank([json['overview']]),
      backdropPath: _firstNonBlank([json['backdrop_path']]),
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      originalLanguage: _firstNonBlank([json['original_language']]),
      genreIds:
          (json['genre_ids'] as List<dynamic>?)?.whereType<int>().toList() ??
          const [],
    );
  }

  final int id;
  final String title;
  final double voteAverage;
  final String? posterPath;
  final String? releaseDate;
  final String? overview;
  final String? backdropPath;
  final int voteCount;
  final String? originalLanguage;
  final List<int> genreIds;

  Movie toEntity() => Movie(
    id: id,
    title: title,
    voteAverage: voteAverage,
    posterPath: posterPath,
    releaseDate: releaseDate,
    overview: overview,
    backdropPath: backdropPath,
    voteCount: voteCount,
    originalLanguage: originalLanguage,
    genreIds: genreIds,
  );

  static String? _firstNonBlank(List<Object?> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
