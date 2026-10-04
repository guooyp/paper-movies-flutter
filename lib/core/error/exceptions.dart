/// Thrown by data sources. The repository turns these into [Failure]s.
class NetworkException implements Exception {}

class ServerException implements Exception {
  const ServerException(this.statusCode);

  final int statusCode;
}

class ParsingException implements Exception {}

class MissingApiKeyException implements Exception {}
