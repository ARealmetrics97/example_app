import 'package:example_app/domain/errors/error.dart';

class InvalidateCredentials extends Error {
  InvalidateCredentials(String message) : super(message);
}

class AccountNotSignIn extends Error {
  AccountNotSignIn(String message) : super(message);
}
