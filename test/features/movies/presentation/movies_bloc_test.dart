import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paper_movies/core/error/failures.dart';
import 'package:paper_movies/features/movies/domain/entities/movie.dart';
import 'package:paper_movies/features/movies/domain/entities/rating_category.dart';
import 'package:paper_movies/features/movies/domain/usecases/get_movies.dart';
import 'package:paper_movies/features/movies/presentation/bloc/movies_bloc.dart';

class _MockGetMovies extends Mock implements GetMovies {}

const _dune = Movie(id: 1, title: 'Dune', voteAverage: 8.2);
const _civilWar = Movie(id: 2, title: 'Civil War', voteAverage: 4.5);
const _movies = [_dune, _civilWar];

void main() {
  late _MockGetMovies getMovies;

  setUp(() => getMovies = _MockGetMovies());

  MoviesBloc build() => MoviesBloc(getMovies: getMovies);

  group('MoviesRequested', () {
    blocTest<MoviesBloc, MoviesState>(
      'emits loading then success with the movies',
      setUp: () => when(() => getMovies()).thenAnswer((_) async => _movies),
      build: build,
      act: (bloc) => bloc.add(const MoviesRequested()),
      expect: () => const [
        MoviesState(status: MoviesStatus.loading),
        MoviesState(status: MoviesStatus.success, movies: _movies),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits loading then failure when the request fails',
      setUp: () => when(() => getMovies()).thenThrow(const NetworkFailure()),
      build: build,
      act: (bloc) => bloc.add(const MoviesRequested()),
      expect: () => const [
        MoviesState(status: MoviesStatus.loading),
        MoviesState(status: MoviesStatus.failure, failure: NetworkFailure()),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'turns an unexpected exception into a failure instead of hanging',
      setUp: () => when(() => getMovies()).thenThrow(StateError('boom')),
      build: build,
      act: (bloc) => bloc.add(const MoviesRequested()),
      errors: () => [isA<StateError>()],
      expect: () => const [
        MoviesState(status: MoviesStatus.loading),
        MoviesState(status: MoviesStatus.failure, failure: UnknownFailure()),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'can retry after an unexpected exception',
      setUp: () {
        when(() => getMovies()).thenThrow(StateError('boom'));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const MoviesRequested());
        await Future<void>.delayed(Duration.zero);
        when(() => getMovies()).thenAnswer((_) async => _movies);
        bloc.add(const MoviesRequested());
      },
      errors: () => [isA<StateError>()],
      verify: (bloc) {
        expect(bloc.state.status, MoviesStatus.success);
        expect(bloc.state.movies, _movies);
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'keeps the existing movies when a refresh fails',
      setUp: () => when(() => getMovies()).thenThrow(const ServerFailure(500)),
      build: build,
      seed: () =>
          const MoviesState(status: MoviesStatus.success, movies: _movies),
      act: (bloc) => bloc.add(const MoviesRequested()),
      expect: () => const [
        MoviesState(status: MoviesStatus.loading, movies: _movies),
        MoviesState(
          status: MoviesStatus.failure,
          movies: _movies,
          failure: ServerFailure(500),
        ),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'ignores a request while one is already running',
      setUp: () => when(() => getMovies()).thenAnswer((_) async => _movies),
      build: build,
      seed: () => const MoviesState(status: MoviesStatus.loading),
      act: (bloc) => bloc.add(const MoviesRequested()),
      expect: () => const <MoviesState>[],
      verify: (_) => verifyNever(() => getMovies()),
    );
  });

  group('filtering', () {
    const loaded = MoviesState(status: MoviesStatus.success, movies: _movies);

    blocTest<MoviesBloc, MoviesState>(
      'selecting a rating filters locally without calling the API',
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const RatingSelected(RatingCategory.great)),
      verify: (bloc) {
        expect(bloc.state.visibleMovies, [_dune]);
        verifyNever(() => getMovies());
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'search is debounced so only the last query is applied',
      build: build,
      seed: () => loaded,
      act: (bloc) async {
        bloc.add(const SearchChanged('c'));
        bloc.add(const SearchChanged('ci'));
        bloc.add(const SearchChanged('civ'));
      },
      wait: searchDebounce + const Duration(milliseconds: 50),
      expect: () => [loaded.copyWith(query: 'civ')],
      verify: (bloc) => expect(bloc.state.visibleMovies, [_civilWar]),
    );

    blocTest<MoviesBloc, MoviesState>(
      'search and rating are applied together',
      build: build,
      seed: () => loaded.copyWith(category: RatingCategory.great),
      act: (bloc) => bloc.add(const SearchChanged('civil')),
      wait: searchDebounce + const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.state.visibleMovies, isEmpty),
    );
  });

  test('starts in the initial state', () {
    expect(build().state, const MoviesState());
  });

  group('state changes', () {
    const loaded = MoviesState(status: MoviesStatus.success, movies: _movies);

    blocTest<MoviesBloc, MoviesState>(
      'a rating selection emits one state with that category',
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const RatingSelected(RatingCategory.good)),
      expect: () => [loaded.copyWith(category: RatingCategory.good)],
    );

    blocTest<MoviesBloc, MoviesState>(
      'clearing the search brings every movie back',
      build: build,
      seed: () => loaded.copyWith(query: 'dune'),
      act: (bloc) => bloc.add(const SearchChanged('')),
      wait: searchDebounce + const Duration(milliseconds: 50),
      expect: () => [loaded],
      verify: (bloc) => expect(bloc.state.visibleMovies, _movies),
    );

    blocTest<MoviesBloc, MoviesState>(
      'searching or filtering keeps a failure that is already showing',
      build: build,
      seed: () => loaded.copyWith(
        status: MoviesStatus.failure,
        failure: const NetworkFailure(),
      ),
      act: (bloc) => bloc.add(const RatingSelected(RatingCategory.bad)),
      verify: (bloc) {
        expect(bloc.state.status, MoviesStatus.failure);
        expect(bloc.state.failure, const NetworkFailure());
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'a successful load clears the failure from an earlier attempt',
      setUp: () => when(() => getMovies()).thenAnswer((_) async => _movies),
      build: build,
      seed: () => const MoviesState(
        status: MoviesStatus.failure,
        failure: NetworkFailure(),
      ),
      act: (bloc) => bloc.add(const MoviesRequested()),
      verify: (bloc) {
        expect(bloc.state.status, MoviesStatus.success);
        expect(bloc.state.failure, isNull);
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'a reload keeps the search and the rating the user picked',
      setUp: () => when(() => getMovies()).thenAnswer((_) async => _movies),
      build: build,
      seed: () =>
          loaded.copyWith(query: 'dune', category: RatingCategory.great),
      act: (bloc) => bloc.add(const MoviesRequested()),
      verify: (bloc) {
        expect(bloc.state.query, 'dune');
        expect(bloc.state.category, RatingCategory.great);
        expect(bloc.state.visibleMovies, [_dune]);
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'loading an empty list is a success, not a failure',
      setUp: () => when(() => getMovies()).thenAnswer((_) async => const []),
      build: build,
      act: (bloc) => bloc.add(const MoviesRequested()),
      expect: () => const [
        MoviesState(status: MoviesStatus.loading),
        MoviesState(status: MoviesStatus.success),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'every kind of failure is passed through to the state',
      setUp: () =>
          when(() => getMovies())
              .thenAnswer((_) async => throw const ParsingFailure()),
      build: build,
      act: (bloc) => bloc.add(const MoviesRequested()),
      verify: (bloc) => expect(bloc.state.failure, const ParsingFailure()),
    );
  });
}
