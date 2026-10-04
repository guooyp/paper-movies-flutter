import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paper_movies/core/error/failures.dart';
import 'package:paper_movies/features/movies/domain/entities/movie.dart';
import 'package:paper_movies/features/movies/domain/usecases/get_movies.dart';
import 'package:paper_movies/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:paper_movies/features/movies/presentation/pages/movie_detail_screen.dart';
import 'package:paper_movies/features/movies/presentation/pages/movies_screen.dart';
import 'package:paper_movies/features/movies/presentation/widgets/movie_card.dart';

class _MockGetMovies extends Mock implements GetMovies {}

// No poster paths on purpose: the placeholder avoids real network image loads.
const _movies = [
  Movie(
    id: 1,
    title: 'Dune: Part Two',
    voteAverage: 8.2,
    releaseDate: '2024-02-27',
    overview: 'Paul Atreides unites with the Fremen.',
  ),
  Movie(id: 2, title: 'Civil War', voteAverage: 4.5, releaseDate: '2024-04-10'),
  Movie(id: 3, title: 'Unreleased', voteAverage: 6.5),
];

const _fullMovie = Movie(
  id: 7,
  title: 'Full Details',
  voteAverage: 7.9,
  releaseDate: '2026-07-29',
  overview: 'Everything is filled in.',
  voteCount: 12345,
  originalLanguage: 'ja',
  genreIds: [28, 878, 424242],
);

const _longMovie = Movie(
  id: 9,
  title: 'A very long movie title that needs more than one line to fit',
  voteAverage: 7.4,
  releaseDate: '2024-01-01',
  overview:
      'A long synopsis that runs over several lines so the page has to wrap '
      'and scroll on a small screen with large text turned on. '
      'It keeps going for a while to make sure.',
);

void main() {
  late _MockGetMovies getMovies;

  setUp(() => getMovies = _MockGetMovies());

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) =>
              MoviesBloc(getMovies: getMovies)..add(const MoviesRequested()),
          child: const MoviesScreen(),
        ),
      ),
    );
  }

  testWidgets('shows a spinner while loading', (tester) async {
    when(() => getMovies()).thenAnswer((_) => Completer<List<Movie>>().future);

    await pumpScreen(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Totals'), findsNothing);
  });

  testWidgets('shows the movies and the total once loaded', (tester) async {
    when(() => getMovies()).thenAnswer((_) async => _movies);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('Feb 27, 2024'), findsOneWidget);
    expect(find.text('Totals = 3'), findsOneWidget);
  });

  testWidgets('shows a fallback when a movie has no release date', (
    tester,
  ) async {
    when(() => getMovies()).thenAnswer((_) async => _movies);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No release date'), findsOneWidget);
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    when(() => getMovies()).thenThrow(const NetworkFailure());

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text(const NetworkFailure().message), findsOneWidget);

    when(() => getMovies()).thenAnswer((_) async => _movies);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('a missing API key shows a plain message, not setup details', (
    tester,
  ) async {
    when(() => getMovies())
        .thenAnswer((_) async => throw const MissingApiKeyFailure());

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('try again later'), findsOneWidget);
    expect(find.textContaining('env.json'), findsNothing);
    expect(find.textContaining('dart-define'), findsNothing);
    expect(find.text('Totals = 0'), findsNothing);
  });

  testWidgets('other failures still offer a retry', (tester) async {
    when(() => getMovies())
        .thenAnswer((_) async => throw const ServerFailure(500));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows the empty state when the API returns nothing', (
    tester,
  ) async {
    when(() => getMovies()).thenAnswer((_) async => const []);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No movies found'), findsOneWidget);
    expect(find.text('Totals = 0'), findsOneWidget);
  });

  testWidgets('tapping a rating chip filters the list', (tester) async {
    when(() => getMovies()).thenAnswer((_) async => _movies);

    await pumpScreen(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Great'));
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text('Civil War'), findsNothing);
    expect(find.text('Totals = 1'), findsOneWidget);
  });

  testWidgets('the search icon opens a field that filters by title', (
    tester,
  ) async {
    when(() => getMovies()).thenAnswer((_) async => _movies);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'civil');
    await tester.pump(searchDebounce + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Civil War'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsNothing);
    expect(find.text('Totals = 1'), findsOneWidget);
  });

  testWidgets('shows the empty state when nothing matches the search', (
    tester,
  ) async {
    when(() => getMovies()).thenAnswer((_) async => _movies);

    await pumpScreen(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump(searchDebounce + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('No movies found'), findsOneWidget);
    expect(find.text('Totals = 0'), findsOneWidget);
  });

  testWidgets('closing the search clears the query', (tester) async {
    when(() => getMovies()).thenAnswer((_) async => _movies);

    await pumpScreen(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'civil');
    await tester.pump(searchDebounce + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Close search'));
    await tester.pump(searchDebounce + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Totals = 3'), findsOneWidget);
  });

  testWidgets('pull to refresh fetches again and replaces the list', (
    tester,
  ) async {
    when(() => getMovies()).thenAnswer((_) async => _movies);

    await pumpScreen(tester);
    await tester.pumpAndSettle();
    verify(() => getMovies()).called(1);

    // The API now returns something different.
    when(() => getMovies()).thenAnswer(
      (_) async => const [Movie(id: 99, title: 'Brand New', voteAverage: 7)],
    );
    await tester.fling(find.text('Dune: Part Two'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => getMovies()).called(1);
    expect(find.text('Brand New'), findsOneWidget);
    expect(find.text('Dune: Part Two'), findsNothing);
    expect(find.text('Totals = 1'), findsOneWidget);
  });

  testWidgets('keeps the list and shows a snackbar when a refresh fails', (
    tester,
  ) async {
    when(() => getMovies()).thenAnswer((_) async => _movies);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    when(() => getMovies()).thenThrow(const ServerFailure(500));
    await tester.fling(find.text('Dune: Part Two'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Dune: Part Two'), findsOneWidget);
    expect(find.text(const ServerFailure(500).message), findsOneWidget);
  });

  group('accessibility and layout', () {
    testWidgets('does not overflow on a small phone with large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      when(() => getMovies()).thenAnswer(
        (_) async => const [
          Movie(
            id: 1,
            title:
                'A very long movie title that needs more than one line to fit',
            voteAverage: 7,
            releaseDate: '2024-01-01',
          ),
        ],
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: MaterialApp(
            home: BlocProvider(
              create: (_) =>
                  MoviesBloc(getMovies: getMovies)
                    ..add(const MoviesRequested()),
              child: const MoviesScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('A very long movie title'), findsOneWidget);
    });

    testWidgets(
      'renders rows with ListView.builder and caps the width on a tablet',
      (tester) async {
        when(() => getMovies()).thenAnswer((_) async => _movies);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1200, 800);
        addTearDown(tester.view.reset);

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (w) => w is ListView && w.scrollDirection == Axis.vertical,
          ),
          findsOneWidget,
        );
        expect(
          tester.getSize(find.byType(MovieCard).first).width,
          lessThan(720),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('shows the rating, or Not rated when there are no votes', (
      tester,
    ) async {
      when(() => getMovies()).thenAnswer(
        (_) async => const [
          Movie(id: 1, title: 'Rated', voteAverage: 7.46),
          Movie(id: 2, title: 'Fresh', voteAverage: 0),
        ],
      );

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('7.5'), findsOneWidget);
      expect(find.text('Not rated'), findsOneWidget);
    });

    testWidgets('a movie card reads as a single item to screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      when(() => getMovies()).thenAnswer((_) async => _movies);

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          RegExp('Dune: Part Two.*Feb 27, 2024', dotAll: true),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('keyboard', () {
    bool searchHasFocus(WidgetTester tester) => tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode
        .hasFocus;

    Future<void> openSearch(WidgetTester tester) async {
      when(() => getMovies()).thenAnswer((_) async => _movies);
      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(
        searchHasFocus(tester),
        isTrue,
        reason: 'search should start focused',
      );
    }

    testWidgets('typing keeps the keyboard open', (tester) async {
      await openSearch(tester);

      await tester.enterText(find.byType(TextField), 'dune');
      await tester.pump(searchDebounce + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isTrue);
    });

    testWidgets('dragging inside the search field does not close it', (
      tester,
    ) async {
      await openSearch(tester);

      await tester.drag(find.byType(TextField), const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isTrue);
    });

    testWidgets('scrolling a list that is long enough closes the keyboard', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 600);
      addTearDown(tester.view.reset);
      final many = [
        for (var i = 0; i < 30; i++)
          Movie(id: i + 1, title: 'Movie $i', voteAverage: 7),
      ];
      when(() => getMovies()).thenAnswer((_) async => many);
      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      await tester.drag(find.text('Movie 1'), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isFalse);
    });

    testWidgets(
      'dragging a short list that cannot scroll closes the keyboard',
      (tester) async {
        await openSearch(tester);

        await tester.drag(find.text('Civil War'), const Offset(0, -150));
        await tester.pumpAndSettle();

        expect(searchHasFocus(tester), isFalse);
      },
    );

    testWidgets('dragging over the header and the chips closes the keyboard', (
      tester,
    ) async {
      await openSearch(tester);

      await tester.drag(find.text('Filter by Rating'), const Offset(0, -150));
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isFalse);
    });

    testWidgets('dragging the chips sideways closes the keyboard', (
      tester,
    ) async {
      await openSearch(tester);

      await tester.drag(find.text('Good'), const Offset(-120, 0));
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isFalse);
    });

    testWidgets('dragging on the empty state closes the keyboard', (
      tester,
    ) async {
      await openSearch(tester);
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pump(searchDebounce + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('No movies found'), findsOneWidget);

      await tester.drag(find.text('No movies found'), const Offset(0, -150));
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isFalse);
    });

    testWidgets('tapping empty space closes the keyboard', (tester) async {
      await openSearch(tester);
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pump(searchDebounce + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No movies found'));
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isFalse);
    });

    testWidgets('tapping a rating chip closes the keyboard and still filters', (
      tester,
    ) async {
      await openSearch(tester);

      await tester.tap(find.text('Great'));
      await tester.pumpAndSettle();

      expect(searchHasFocus(tester), isFalse);
      expect(find.text('Totals = 1'), findsOneWidget);
    });
  });

  group('detail page', () {
    testWidgets('tapping a card opens its details and back returns', (
      tester,
    ) async {
      when(() => getMovies()).thenAnswer((_) async => _movies);

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dune: Part Two'));
      await tester.pumpAndSettle();

      expect(find.byType(MovieDetailScreen), findsOneWidget);
      expect(
        find.text('Paul Atreides unites with the Fremen.'),
        findsOneWidget,
      );
      expect(find.text('8.2'), findsOneWidget);
      expect(find.text('Feb 27, 2024'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(MovieDetailScreen), findsNothing);
      expect(find.text('Totals = 3'), findsOneWidget);
    });

    testWidgets('shows genres, votes and language', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MovieDetailScreen(movie: _fullMovie)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Science Fiction'), findsOneWidget);
      expect(find.text('7.9'), findsOneWidget);
      expect(find.text('12.3K'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);
      expect(find.text('Jul 29, 2026'), findsOneWidget);
    });

    testWidgets('leaves out what it does not have', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MovieDetailScreen(
            movie: Movie(id: 1, title: 'Bare', voteAverage: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not rated'), findsOneWidget);
      expect(find.text('-'), findsOneWidget); // language
      expect(find.text('0'), findsOneWidget); // votes
      expect(find.text('No synopsis available.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls, and the back button stays reachable while it does', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 500);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MovieDetailScreen(movie: _longMovie),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        greaterThan(0),
      );

      // Scrolled well down, and the back button is still there to tap.
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(MovieDetailScreen), findsNothing);
    });

    testWidgets('falls back when a movie has no overview or date', (
      tester,
    ) async {
      when(() => getMovies()).thenAnswer((_) async => _movies);

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unreleased'));
      await tester.pumpAndSettle();

      expect(find.text('No synopsis available.'), findsOneWidget);
      expect(find.text('No release date'), findsOneWidget);
    });

    testWidgets('lays out side by side on a wide screen without overflow', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 700);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: MovieDetailScreen(movie: _longMovie)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow on a small phone with large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: MaterialApp(home: MovieDetailScreen(movie: _longMovie)),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
