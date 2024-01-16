import 'package:example_app/domain/errors/error.dart';

class UnknownError extends Error {
  UnknownError(String message) : super(message);
}
