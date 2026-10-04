import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paper_movies/core/error/failures.dart';
import 'package:paper_movies/features/movies/domain/entities/movie.dart';
import 'package:paper_movies/features/movies/domain/repositories/movies_repository.dart';
import 'package:paper_movies/features/movies/domain/usecases/get_movies.dart';

class _MockRepository extends Mock implements MoviesRepository {}

void main() {
  late _MockRepository repository;
  late GetMovies getMovies;

  setUp(() {
    repository = _MockRepository();
    getMovies = GetMovies(repository);
  });

  test('returns what the repository returns', () async {
    const movies = [Movie(id: 1, title: 'A', voteAverage: 5)];
    when(() => repository.getMovies()).thenAnswer((_) async => movies);

    expect(await getMovies(), movies);
  });

  test('lets failures through untouched', () {
    when(() => repository.getMovies())
        .thenAnswer((_) async => throw const NetworkFailure());

    expect(getMovies(), throwsA(const NetworkFailure()));
  });
}
