import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/features/movies/presentation/widgets/search_field.dart';

void main() {
  late List<String> changes;

  setUp(() => changes = []);

  Future<void> pumpField(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SearchField(onChanged: changes.add)),
    ),
  );

  testWidgets('shows the hint and no clear button when empty', (tester) async {
    await pumpField(tester);

    expect(find.text('Search movie title'), findsOneWidget);
    expect(find.byTooltip('Clear'), findsNothing);
  });

  testWidgets('reports every change as the user types', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), 'dun');
    await tester.enterText(find.byType(TextField), 'dune');

    expect(changes, ['dun', 'dune']);
  });

  testWidgets('shows a clear button once there is text', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), 'dune');
    await tester.pump();

    expect(find.byTooltip('Clear'), findsOneWidget);
  });

  testWidgets('the clear button empties the field and reports it', (
    tester,
  ) async {
    await pumpField(tester);
    await tester.enterText(find.byType(TextField), 'dune');
    await tester.pump();

    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(changes.last, '');
    expect(find.byTooltip('Clear'), findsNothing);
  });

  testWidgets('takes focus as soon as it appears', (tester) async {
    await pumpField(tester);

    expect(tester.widget<TextField>(find.byType(TextField)).autofocus, isTrue);
  });
}
