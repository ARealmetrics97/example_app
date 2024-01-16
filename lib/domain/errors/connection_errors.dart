import "package:example_app/domain/errors/error.dart";

class NetworkError extends Error {
  NetworkError(String message): super(message);
}