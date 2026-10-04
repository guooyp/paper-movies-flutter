import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/features/movies/domain/entities/movie.dart';
import 'package:paper_movies/features/movies/domain/entities/rating_category.dart';
import 'package:paper_movies/features/movies/domain/usecases/filter_movies.dart';

Movie movie(String title, double rating) =>
    Movie(id: title.hashCode, title: title, voteAverage: rating);

void main() {
  final movies = [
    movie('Unrated', 0),
    movie('Civil War', 3.9),
    movie('The Fall Guy', 4.0),
    movie('Dune: Part Two', 6.0),
    movie('Furiosa', 7.9),
    movie('Dune', 8.0),
    movie('Perfect', 9.0),
  ];

  List<String> titles(RatingCategory category, [String query = '']) =>
      filterMovies(
        movies,
        query: query,
        category: category,
      ).map((m) => m.title).toList();

  test('All keeps everything, including unrated movies', () {
    expect(titles(RatingCategory.all), hasLength(7));
  });

  test('a category includes movies exactly at its minimum', () {
    expect(titles(RatingCategory.bad), isNot(contains('Unrated')));
    expect(titles(RatingCategory.bad), isNot(contains('Civil War')));
    expect(titles(RatingCategory.bad), contains('The Fall Guy'));
    expect(titles(RatingCategory.good), isNot(contains('The Fall Guy')));
    expect(titles(RatingCategory.good), contains('Dune: Part Two'));
    expect(titles(RatingCategory.great), ['Dune', 'Perfect']);
    expect(titles(RatingCategory.recommend), ['Perfect']);
  });

  test('search is case insensitive and ignores surrounding spaces', () {
    expect(titles(RatingCategory.all, '  DUNE '), ['Dune: Part Two', 'Dune']);
  });

  test('search and rating combine', () {
    expect(titles(RatingCategory.great, 'dune'), ['Dune']);
  });

  test('returns an empty list when nothing matches', () {
    expect(titles(RatingCategory.all, 'zzz'), isEmpty);
    expect(filterMovies([], query: '', category: RatingCategory.all), isEmpty);
  });

  test('blank query does not filter', () {
    expect(titles(RatingCategory.all, '   '), hasLength(7));
  });

  test('keeps the original order', () {
    expect(titles(RatingCategory.bad), [
      'The Fall Guy',
      'Dune: Part Two',
      'Furiosa',
      'Dune',
      'Perfect',
    ]);
  });

  test('does not change the list it is given', () {
    final copy = List<Movie>.of(movies);

    filterMovies(movies, query: 'dune', category: RatingCategory.great);

    expect(movies, copy);
  });

  test('treats the search as plain text, not a pattern', () {
    final special = [movie('Mission: Impossible (2024)', 7), movie('A.B', 7)];

    expect(
      filterMovies(special, query: '(2024)', category: RatingCategory.all),
      [special.first],
    );
    expect(filterMovies(special, query: 'a.b', category: RatingCategory.all), [
      special.last,
    ]);
    expect(
      filterMovies(special, query: '.*', category: RatingCategory.all),
      isEmpty,
    );
  });

  test('matches anywhere in the title, not only at the start', () {
    expect(titles(RatingCategory.all, 'part'), ['Dune: Part Two']);
    expect(titles(RatingCategory.all, 'fall'), ['The Fall Guy']);
  });

  test('matches accented titles', () {
    final french = [movie('Un père idéal', 6)];

    expect(
      filterMovies(french, query: 'père', category: RatingCategory.all),
      french,
    );
  });
}
