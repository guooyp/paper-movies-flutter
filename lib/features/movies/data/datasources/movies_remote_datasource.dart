import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/movie_model.dart';

class MoviesRemoteDataSource {
  MoviesRemoteDataSource({
    required this._client,
    this._apiKey = ApiConfig.apiKey,
    this.timeout = const Duration(seconds: 15),
  });

  final http.Client _client;
  final String _apiKey;
  final Duration timeout;

  Future<List<MovieModel>> fetchPopularMovies() async {
    if (_apiKey.isEmpty) {
      debugPrint(
        'TMDB_API_KEY is not set. Copy env.json.example to env.json and run '
        'with --dart-define-from-file=env.json (see README).',
      );
      throw MissingApiKeyException();
    }

    final uri = Uri.https(ApiConfig.host, '/3/discover/movie', {
      'api_key': _apiKey,
      'include_adult': 'false',
      'include_video': 'false',
      'language': 'en-US',
      'page': '1',
      'sort_by': 'popularity.desc',
    });

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on IOException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    }

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    try {
      // JSON is UTF-8. response.body would guess Latin-1 if the server leaves
      // the charset off the Content-Type header and mangle accented titles.
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>;
      return results
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw ParsingException();
    } on TypeError {
      throw ParsingException();
    }
  }
}
