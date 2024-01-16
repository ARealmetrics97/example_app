import 'package:example_app/domain/errors/error.dart';

sealed class Response<T> {}

class Success<T> extends Response<T> {
  T value;

  Success(this.value);
}

class Fail<T> extends Response<T> {
  Error error;

  Fail(this.error);
}
