import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/features/movies/data/models/movie_model.dart';

void main() {
  group('MovieModel.fromJson', () {
    test('parses a complete movie', () {
      final model = MovieModel.fromJson({
        'id': 10,
        'title': 'Dune: Part Two',
        'poster_path': '/dune.jpg',
        'release_date': '2024-02-27',
        'vote_average': 8.2,
      });

      expect(model.id, 10);
      expect(model.title, 'Dune: Part Two');
      expect(model.posterPath, '/dune.jpg');
      expect(model.releaseDate, '2024-02-27');
      expect(model.voteAverage, 8.2);
    });

    test('accepts an integer vote_average', () {
      final model = MovieModel.fromJson({
        'id': 1,
        'title': 'A',
        'vote_average': 7,
      });

      expect(model.voteAverage, 7.0);
    });

    test('treats null and blank optional fields as missing', () {
      final model = MovieModel.fromJson({
        'id': 1,
        'title': 'A',
        'poster_path': null,
        'release_date': '  ',
        'vote_average': null,
      });

      expect(model.posterPath, isNull);
      expect(model.releaseDate, isNull);
      expect(model.voteAverage, 0);
    });

    test('falls back to original_title, then to a placeholder', () {
      final withOriginal = MovieModel.fromJson({
        'id': 1,
        'title': '',
        'original_title': 'Un père idéal',
      });
      final withNothing = MovieModel.fromJson({'id': 2, 'title': null});

      expect(withOriginal.title, 'Un père idéal');
      expect(withNothing.title, 'Untitled');
    });

    test('reads the overview and treats a blank one as missing', () {
      final withText = MovieModel.fromJson({'id': 1, 'overview': 'A story.'});
      final blank = MovieModel.fromJson({'id': 2, 'overview': ''});

      expect(withText.overview, 'A story.');
      expect(blank.overview, isNull);
      expect(withText.toEntity().overview, 'A story.');
    });

    test('reads backdrop, votes, language and genres', () {
      final model = MovieModel.fromJson({
        'id': 1,
        'backdrop_path': '/back.jpg',
        'vote_count': 1234,
        'original_language': 'en',
        'genre_ids': [28, 12],
      });

      expect(model.backdropPath, '/back.jpg');
      expect(model.voteCount, 1234);
      expect(model.originalLanguage, 'en');
      expect(model.genreIds, [28, 12]);
      expect(model.toEntity().genreIds, [28, 12]);
    });

    test('defaults the new fields when they are missing or odd', () {
      final model = MovieModel.fromJson({
        'id': 1,
        'backdrop_path': null,
        'vote_count': null,
        'genre_ids': [28, 'x', null],
      });

      expect(model.backdropPath, isNull);
      expect(model.voteCount, 0);
      expect(model.originalLanguage, isNull);
      expect(model.genreIds, [28]);
      expect(MovieModel.fromJson({'id': 2}).genreIds, isEmpty);
    });

    test('throws when id is missing', () {
      expect(
        () => MovieModel.fromJson({'title': 'A'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
