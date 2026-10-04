part of 'movies_bloc.dart';

enum MoviesStatus { initial, loading, success, failure }

class MoviesState extends Equatable {
  const MoviesState({
    this.status = MoviesStatus.initial,
    this.movies = const [],
    this.query = '',
    this.category = RatingCategory.all,
    this.failure,
  });

  final MoviesStatus status;

  /// Everything the API returned. Filtering never touches this list.
  final List<Movie> movies;
  final String query;
  final RatingCategory category;
  final Failure? failure;

  List<Movie> get visibleMovies =>
      filterMovies(movies, query: query, category: category);

  MoviesState copyWith({
    MoviesStatus? status,
    List<Movie>? movies,
    String? query,
    RatingCategory? category,
    Failure? failure,
  }) {
    return MoviesState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      query: query ?? this.query,
      category: category ?? this.category,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, movies, query, category, failure];
}
