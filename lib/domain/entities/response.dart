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

/*@freezed
sealed class ResponseStream<T> with _$ResponseStream {
  const factory ResponseStream.loading() = LoadingStream;
  const factory ResponseStream.success(T data) = SuccessStream;
  const factory ResponseStream.fail(Error error) = FailStream;
}*/

sealed class ResponseStream<T> {}

class LoadingStream<T> extends ResponseStream<T> {}

class SuccessStream<T> extends ResponseStream<T> {
  T value;

  SuccessStream(this.value);
}

class FailStream<T> extends ResponseStream<T> {
  Error error;

  FailStream(this.error);
}
