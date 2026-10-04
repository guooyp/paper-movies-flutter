import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure()
    : super('No internet connection. Check your network and try again.');
}

class ServerFailure extends Failure {
  const ServerFailure(int statusCode)
    : super('The server returned an error ($statusCode). Please try again.');
}

/// A setup problem, not something the user can fix, so they get a plain message.
/// The developer hint is logged where the problem is detected.
class MissingApiKeyFailure extends Failure {
  const MissingApiKeyFailure()
    : super('We can\'t load movies right now. Please try again later.');
}

/// Anything we didn't plan for. Shown generically, details go to the observer.
class UnknownFailure extends Failure {
  const UnknownFailure() : super('Something went wrong. Please try again.');
}

class ParsingFailure extends Failure {
  const ParsingFailure()
    : super('We received an unexpected response from the server.');
}
