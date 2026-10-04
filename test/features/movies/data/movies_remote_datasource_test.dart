import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paper_movies/core/error/exceptions.dart';
import 'package:paper_movies/features/movies/data/datasources/movies_remote_datasource.dart';

/// Builds a response the way a real server does: JSON as UTF-8 bytes.
http.Response _ok(String body) => http.Response.bytes(utf8.encode(body), 200);

void main() {
  final fixture = File('test/fixtures/movies_response.json').readAsStringSync();

  MoviesRemoteDataSource dataSource(MockClientHandler handler) {
    return MoviesRemoteDataSource(
      client: MockClient(handler),
      apiKey: 'test-key',
      timeout: const Duration(milliseconds: 50),
    );
  }

  test('returns parsed movies on a 200 response', () async {
    final result = await dataSource((_) async => _ok(fixture))
        .fetchPopularMovies();

    expect(result.map((m) => m.id), [653346, 823464, 1]);
  });

  test('sends the key and sort order as query parameters', () async {
    late Uri requested;
    await dataSource((request) async {
      requested = request.url;
      return _ok(fixture);
    }).fetchPopularMovies();

    expect(requested.host, 'api.themoviedb.org');
    expect(requested.path, '/3/discover/movie');
    expect(requested.queryParameters['api_key'], 'test-key');
    expect(requested.queryParameters['sort_by'], 'popularity.desc');
    expect(requested.queryParameters['page'], '1');
  });

  test('returns an empty list when results is empty', () async {
    final result = await dataSource(
      (_) async => http.Response('{"results": []}', 200),
    ).fetchPopularMovies();

    expect(result, isEmpty);
  });

  test('throws ServerException with the status code on non-200', () {
    expect(
      dataSource((_) async => http.Response('nope', 401)).fetchPopularMovies(),
      throwsA(isA<ServerException>().having((e) => e.statusCode, 'code', 401)),
    );
  });

  test('throws ParsingException on invalid JSON', () {
    expect(
      dataSource((_) async => http.Response('<html>', 200))
          .fetchPopularMovies(),
      throwsA(isA<ParsingException>()),
    );
  });

  test('throws ParsingException when results is missing', () {
    expect(
      dataSource((_) async => http.Response('{}', 200)).fetchPopularMovies(),
      throwsA(isA<ParsingException>()),
    );
  });

  test('throws ParsingException when an item is malformed', () {
    expect(
      dataSource(
        (_) async => http.Response('{"results": [{"title": "no id"}]}', 200),
      ).fetchPopularMovies(),
      throwsA(isA<ParsingException>()),
    );
  });

  test('throws NetworkException when offline', () {
    expect(
      dataSource((_) async => throw const SocketException('offline'))
          .fetchPopularMovies(),
      throwsA(isA<NetworkException>()),
    );
  });

  test('throws NetworkException on a client error', () {
    expect(
      dataSource((_) async => throw http.ClientException('reset'))
          .fetchPopularMovies(),
      throwsA(isA<NetworkException>()),
    );
  });

  test('throws NetworkException on timeout', () {
    expect(
      dataSource((_) => Completer<http.Response>().future).fetchPopularMovies(),
      throwsA(isA<NetworkException>()),
    );
  });

  test('throws NetworkException on a TLS failure', () {
    expect(
      dataSource((_) async => throw const HandshakeException('bad cert'))
          .fetchPopularMovies(),
      throwsA(isA<NetworkException>()),
    );
  });

  test('logs a hint for the developer when the API key is empty', () async {
    final printed = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
    addTearDown(() => debugPrint = original);

    await expectLater(
      MoviesRemoteDataSource(
        client: MockClient((_) async => _ok(fixture)),
        apiKey: '',
      ).fetchPopularMovies(),
      throwsA(isA<MissingApiKeyException>()),
    );

    expect(printed.single, contains('TMDB_API_KEY'));
    expect(printed.single, contains('env.json'));
  });

  test('fails fast without a request when the API key is empty', () {
    var called = false;
    final source = MoviesRemoteDataSource(
      client: MockClient((_) async {
        called = true;
        return _ok(fixture);
      }),
      apiKey: '',
    );

    expect(source.fetchPopularMovies(), throwsA(isA<MissingApiKeyException>()));
    expect(called, isFalse);
  });

  group('unexpected response shapes', () {
    for (final entry in {
      'a JSON array instead of an object': '[]',
      'results that is not a list': '{"results": "nope"}',
      'results that is null': '{"results": null}',
      'an item that is not an object': '{"results": [1, 2]}',
      'an id that is not an int': '{"results": [{"id": "1"}]}',
      'a rating that is not a number':
          '{"results": [{"id": 1, "vote_average": "high"}]}',
      'an empty body': '',
    }.entries) {
      test('throws ParsingException for ${entry.key}', () {
        expect(
          dataSource((_) async => http.Response(entry.value, 200))
              .fetchPopularMovies(),
          throwsA(isA<ParsingException>()),
        );
      });
    }
  });

  test('keeps the order the API returned', () async {
    const body = '{"results": [{"id": 3}, {"id": 1}, {"id": 2}]}';

    final result = await dataSource((_) async => http.Response(body, 200))
        .fetchPopularMovies();

    expect(result.map((m) => m.id), [3, 1, 2]);
  });

  test('reads a body with non-ASCII titles correctly', () async {
    final body = http.Response.bytes(
      utf8.encode('{"results": [{"id": 1, "title": "Un père idéal"}]}'),
      200,
    );

    final result = await dataSource((_) async => body).fetchPopularMovies();

    expect(result.single.title, 'Un père idéal');
  });

  test('treats every non-200 status as a ServerException', () async {
    for (final code in [201, 301, 400, 404, 429, 500, 503]) {
      await expectLater(
        dataSource((_) async => http.Response('', code)).fetchPopularMovies(),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'code', code),
        ),
        reason: 'status $code',
      );
    }
  });
}
