import '../entities/movie.dart';

abstract class MoviesRepository {
  /// Throws a [Failure] when the movies can't be loaded.
  Future<List<Movie>> getMovies();
}
