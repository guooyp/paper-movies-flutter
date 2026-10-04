import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/core/app_bloc_observer.dart';

class _TestCubit extends Cubit<int> {
  _TestCubit() : super(0);
}

void main() {
  late DebugPrintCallback originalDebugPrint;
  late List<String> printed;

  setUp(() {
    originalDebugPrint = debugPrint;
    printed = [];
    debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
  });

  tearDown(() => debugPrint = originalDebugPrint);

  test('logs the bloc type, the error and the stack trace', () {
    final cubit = _TestCubit();
    addTearDown(cubit.close);

    AppBlocObserver().onError(cubit, StateError('boom'), StackTrace.current);

    expect(printed, hasLength(1));
    expect(printed.single, contains('_TestCubit'));
    expect(printed.single, contains('boom'));
    expect(printed.single, contains('main'));
  });

  test('is a BlocObserver so it can be installed globally', () {
    expect(AppBlocObserver(), isA<BlocObserver>());
  });
}
