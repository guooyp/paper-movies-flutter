import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/core/error/failures.dart';
import 'package:paper_movies/features/movies/domain/entities/movie.dart';
import 'package:paper_movies/features/movies/domain/entities/rating_category.dart';
import 'package:paper_movies/features/movies/presentation/bloc/movies_bloc.dart';

const _dune = Movie(id: 1, title: 'Dune', voteAverage: 8.2);
const _civilWar = Movie(id: 2, title: 'Civil War', voteAverage: 4.5);
const _fallGuy = Movie(id: 3, title: 'The Fall Guy', voteAverage: 7);

void main() {
  group('MoviesState', () {
    test('starts empty, idle, unfiltered and without a failure', () {
      const state = MoviesState();

      expect(state.status, MoviesStatus.initial);
      expect(state.movies, isEmpty);
      expect(state.query, '');
      expect(state.category, RatingCategory.all);
      expect(state.failure, isNull);
      expect(state.visibleMovies, isEmpty);
    });

    test('copyWith replaces only what it is given', () {
      const state = MoviesState(
        status: MoviesStatus.success,
        movies: [_dune],
        query: 'du',
        category: RatingCategory.good,
      );

      final next = state.copyWith(query: 'dun');

      expect(next.query, 'dun');
      expect(next.status, MoviesStatus.success);
      expect(next.movies, [_dune]);
      expect(next.category, RatingCategory.good);
    });

    test('copyWith clears the failure unless one is passed', () {
      const failed = MoviesState(
        status: MoviesStatus.failure,
        failure: NetworkFailure(),
      );

      expect(failed.copyWith(status: MoviesStatus.loading).failure, isNull);
      expect(
        failed.copyWith(failure: failed.failure).failure,
        const NetworkFailure(),
      );
    });

    test('visibleMovies applies the search and the rating together', () {
      const state = MoviesState(
        status: MoviesStatus.success,
        movies: [_dune, _civilWar, _fallGuy],
      );

      expect(state.visibleMovies, [_dune, _civilWar, _fallGuy]);
      expect(state.copyWith(category: RatingCategory.good).visibleMovies, [
        _dune,
        _fallGuy,
      ]);
      expect(state.copyWith(query: 'fall').visibleMovies, [_fallGuy]);
      expect(
        state
            .copyWith(query: 'the', category: RatingCategory.great)
            .visibleMovies,
        isEmpty,
      );
    });

    test('visibleMovies never changes the full list', () {
      const state = MoviesState(
        movies: [_dune, _civilWar],
        category: RatingCategory.great,
      );

      expect(state.visibleMovies, [_dune]);
      expect(state.movies, [_dune, _civilWar]);
    });

    test('is equal when every field matches', () {
      const a = MoviesState(status: MoviesStatus.success, movies: [_dune]);
      const b = MoviesState(status: MoviesStatus.success, movies: [_dune]);

      expect(a, b);
      expect(a, isNot(a.copyWith(query: 'x')));
      expect(a, isNot(a.copyWith(status: MoviesStatus.loading)));
      expect(a, isNot(a.copyWith(category: RatingCategory.bad)));
      expect(a, isNot(a.copyWith(movies: [_civilWar])));
    });
  });

  group('MoviesEvent', () {
    test('events with the same data are equal', () {
      expect(const MoviesRequested(), const MoviesRequested());
      expect(const SearchChanged('a'), const SearchChanged('a'));
      expect(
        const RatingSelected(RatingCategory.good),
        const RatingSelected(RatingCategory.good),
      );
    });

    test('events with different data are not equal', () {
      expect(const SearchChanged('a'), isNot(const SearchChanged('b')));
      expect(
        const RatingSelected(RatingCategory.good),
        isNot(const RatingSelected(RatingCategory.great)),
      );
      expect(const MoviesRequested(), isNot(const SearchChanged('')));
    });
  });
}
