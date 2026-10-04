import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/features/movies/presentation/widgets/movie_poster.dart';

void main() {
  testWidgets('shows a placeholder icon when there is no poster', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: MoviePoster(path: null, width: 62, height: 92)),
      ),
    );

    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
  });

  testWidgets('the placeholder keeps the size it was given', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: MoviePoster(path: null, width: 62, height: 92)),
      ),
    );

    expect(tester.getSize(find.byType(MoviePoster)), const Size(62, 92));
  });

  testWidgets('rounds the corners by the radius it was given', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: MoviePoster(path: null, width: 10, height: 10, radius: 12),
        ),
      ),
    );

    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.circular(12));
  });
}
