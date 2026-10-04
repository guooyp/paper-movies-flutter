import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  const Movie({
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

  @override
  List<Object?> get props => [
    id,
    title,
    voteAverage,
    posterPath,
    releaseDate,
    overview,
    backdropPath,
    voteCount,
    originalLanguage,
    genreIds,
  ];
}
