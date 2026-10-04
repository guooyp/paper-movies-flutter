import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paper_movies/core/error/exceptions.dart';
import 'package:paper_movies/core/error/failures.dart';
import 'package:paper_movies/features/movies/data/datasources/movies_remote_datasource.dart';
import 'package:paper_movies/features/movies/data/models/movie_model.dart';
import 'package:paper_movies/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:paper_movies/features/movies/domain/entities/movie.dart';

class _MockRemote extends Mock implements MoviesRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late MoviesRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = MoviesRepositoryImpl(remote);
  });

  test('maps models to entities', () async {
    when(() => remote.fetchPopularMovies()).thenAnswer(
      (_) async => [const MovieModel(id: 1, title: 'A', voteAverage: 5)],
    );

    expect(await repository.getMovies(), const [
      Movie(id: 1, title: 'A', voteAverage: 5),
    ]);
  });

  test('maps NetworkException to NetworkFailure', () {
    when(() => remote.fetchPopularMovies()).thenThrow(NetworkException());

    expect(repository.getMovies(), throwsA(isA<NetworkFailure>()));
  });

  test('maps ServerException to ServerFailure', () {
    when(() => remote.fetchPopularMovies())
        .thenThrow(const ServerException(500));

    expect(repository.getMovies(), throwsA(const ServerFailure(500)));
  });

  test('maps ParsingException to ParsingFailure', () {
    when(() => remote.fetchPopularMovies()).thenThrow(ParsingException());

    expect(repository.getMovies(), throwsA(isA<ParsingFailure>()));
  });

  test('maps MissingApiKeyException to MissingApiKeyFailure', () {
    when(() => remote.fetchPopularMovies()).thenThrow(MissingApiKeyException());

    expect(repository.getMovies(), throwsA(isA<MissingApiKeyFailure>()));
  });
}
