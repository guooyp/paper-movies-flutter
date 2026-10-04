import 'package:flutter_test/flutter_test.dart';
import 'package:paper_movies/core/error/failures.dart';

void main() {
  test('every failure is also an Exception so it can be thrown', () {
    expect(const NetworkFailure(), isA<Exception>());
    expect(const ServerFailure(500), isA<Exception>());
    expect(const ParsingFailure(), isA<Exception>());
    expect(const MissingApiKeyFailure(), isA<Exception>());
    expect(const UnknownFailure(), isA<Exception>());
  });

  test('messages are written for the user, not for developers', () {
    expect(const NetworkFailure().message, contains('internet'));
    expect(const ParsingFailure().message, contains('unexpected response'));
    expect(const UnknownFailure().message, contains('Something went wrong'));
  });

  test('the server failure message includes the status code', () {
    expect(const ServerFailure(503).message, contains('503'));
    expect(const ServerFailure(401).message, contains('401'));
  });

  test('the missing key message is for the user, not the developer', () {
    final message = const MissingApiKeyFailure().message;

    expect(message, contains('try again later'));
    expect(message, isNot(contains('key')));
    expect(message, isNot(contains('env.json')));
  });

  test('failures with the same message are equal', () {
    expect(const NetworkFailure(), const NetworkFailure());
    expect(const ServerFailure(500), const ServerFailure(500));
    expect(const ServerFailure(500), isNot(const ServerFailure(502)));
    expect(const NetworkFailure(), isNot(const ParsingFailure()));
  });
}
