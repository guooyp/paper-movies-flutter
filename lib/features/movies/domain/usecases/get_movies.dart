import '../entities/movie.dart';
import '../repositories/movies_repository.dart';

class GetMovies {
  const GetMovies(this._repository);

  final MoviesRepository _repository;

  Future<List<Movie>> call() => _repository.getMovies();
}
