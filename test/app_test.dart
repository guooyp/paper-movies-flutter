import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paper_movies/core/error/failures.dart';
import 'package:paper_movies/features/movies/domain/entities/movie.dart';
import 'package:paper_movies/features/movies/domain/usecases/get_movies.dart';
import 'package:paper_movies/main.dart';

class _MockGetMovies extends Mock implements GetMovies {}

void main() {
  late _MockGetMovies getMovies;

  setUp(() => getMovies = _MockGetMovies());

  testWidgets('loads the movies as soon as the app starts', (tester) async {
    when(() => getMovies()).thenAnswer(
      (_) async => const [Movie(id: 1, title: 'Dune', voteAverage: 8)],
    );

    await tester.pumpWidget(MoviesApp(getMovies: getMovies));
    await tester.pumpAndSettle();

    verify(() => getMovies()).called(1);
    expect(find.text('Movie List'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
  });

  testWidgets('shows an error with a retry when the first load fails', (
    tester,
  ) async {
    when(() => getMovies())
        .thenAnswer((_) async => throw const NetworkFailure());

    await tester.pumpWidget(MoviesApp(getMovies: getMovies));
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('uses the light theme by default and the dark one on request', (
    tester,
  ) async {
    when(() => getMovies()).thenAnswer((_) async => const []);

    await tester.pumpWidget(MoviesApp(getMovies: getMovies));
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.theme!.colorScheme.brightness, Brightness.light);
    expect(app.darkTheme!.colorScheme.brightness, Brightness.dark);
    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
