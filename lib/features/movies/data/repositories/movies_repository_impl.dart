import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_remote_datasource.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  const MoviesRepositoryImpl(this._remote);

  final MoviesRemoteDataSource _remote;

  @override
  Future<List<Movie>> getMovies() async {
    try {
      final models = await _remote.fetchPopularMovies();
      return models.map((model) => model.toEntity()).toList();
    } on NetworkException {
      throw const NetworkFailure();
    } on ServerException catch (e) {
      throw ServerFailure(e.statusCode);
    } on ParsingException {
      throw const ParsingFailure();
    } on MissingApiKeyException {
      throw const MissingApiKeyFailure();
    }
  }
}
