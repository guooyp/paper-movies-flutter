import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/features/movies/domain/entities/movie.dart';
import 'package:paper_movies/features/movies/domain/entities/rating_category.dart';

void main() {
  group('Movie', () {
    const movie = Movie(id: 1, title: 'A', voteAverage: 7);

    test('only needs an id, title and rating', () {
      expect(movie.posterPath, isNull);
      expect(movie.backdropPath, isNull);
      expect(movie.releaseDate, isNull);
      expect(movie.overview, isNull);
      expect(movie.originalLanguage, isNull);
      expect(movie.voteCount, 0);
      expect(movie.genreIds, isEmpty);
    });

    test('is equal when every field matches', () {
      const same = Movie(id: 1, title: 'A', voteAverage: 7);
      expect(movie, same);
      expect(movie.hashCode, same.hashCode);
    });

    test('is different when any field differs', () {
      expect(movie, isNot(const Movie(id: 2, title: 'A', voteAverage: 7)));
      expect(movie, isNot(const Movie(id: 1, title: 'B', voteAverage: 7)));
      expect(movie, isNot(const Movie(id: 1, title: 'A', voteAverage: 7.1)));
      expect(
        movie,
        isNot(const Movie(id: 1, title: 'A', voteAverage: 7, posterPath: '/p')),
      );
      expect(
        movie,
        isNot(const Movie(id: 1, title: 'A', voteAverage: 7, genreIds: [28])),
      );
      expect(
        movie,
        isNot(const Movie(id: 1, title: 'A', voteAverage: 7, voteCount: 3)),
      );
    });
  });

  group('RatingCategory', () {
    test('lists the categories in the order the chips are shown', () {
      expect(RatingCategory.values.map((c) => c.name), [
        'All',
        'Bad',
        'Good',
        'Great',
        'Recommend',
      ]);
    });

    test('gets stricter from left to right', () {
      expect(RatingCategory.values.map((c) => c.minRating), [0, 4, 6, 8, 9]);
      final ratings = RatingCategory.values.map((c) => c.minRating).toList();
      expect([...ratings]..sort(), ratings);
    });

    test('All lets everything through, including unrated movies', () {
      expect(RatingCategory.all.minRating, 0);
    });

    test('is equal by name and minimum', () {
      expect(const RatingCategory('Bad', 4), RatingCategory.bad);
      expect(const RatingCategory('Bad', 5), isNot(RatingCategory.bad));
      expect(const RatingCategory('Other', 4), isNot(RatingCategory.bad));
    });
  });
}
