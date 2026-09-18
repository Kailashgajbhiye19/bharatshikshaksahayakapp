/// [Failure] represents a domain-level error.
/// Instead of throwing raw exceptions, repositories return Failures to the UI.
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([String? message]) : super(message ?? "A server error occurred. Please try again later.");
}

class NetworkFailure extends Failure {
  NetworkFailure() : super("No internet connection. Please check your network.");
}

class CacheFailure extends Failure {
  CacheFailure() : super("Failed to access local data.");
}

class AuthFailure extends Failure {
  AuthFailure(super.message);
}
