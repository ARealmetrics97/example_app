import 'package:example_app/domain/errors/authentication_errors.dart';
import 'package:example_app/domain/repositories/auth_repository.dart';
import 'package:example_app/domain/entities/response.dart';
import 'package:example_app/domain/entities/user.dart';
import 'package:example_app/domain/repositories/user_repository.dart';

class LoginUserUC {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LoginUserUC(this._authRepository, this._userRepository);

  Future<Response<User>> execute(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return Fail<User>(InvalidateCredentials("Credenciales invalidas"));
    }
    final response = await _authRepository.loginUser(email, password);
    switch (response) {
      case Success():
        final infoAuthentication = response.value;
        final userExists =
            await _userRepository.verifyUserExists(infoAuthentication.userId);
        if (!userExists) {
          return Fail<User>(AccountNotSignIn("Esta cuenta no esta registrada"));
        }
        final user = await _userRepository.getUser(infoAuthentication.userId);
        return Success(user);
      case Fail():
        final error = Fail<User>(response.error);
        return Future.value(error);
    }
  }

  Stream<ResponseStream<User>> executeV2(String email, String password) async* {
    yield LoadingStream<User>();
    if (email.isEmpty || password.isEmpty) {
      yield FailStream(InvalidateCredentials("Credenciales invalidas"));
      return;
    }
    final response = await _authRepository.loginUser(email, password);
    switch (response) {
      case Success():
        final infoAuthentication = response.value;
        final userExists =
            await _userRepository.verifyUserExists(infoAuthentication.userId);
        if (!userExists) {
          yield FailStream(AccountNotSignIn("Esta cuenta no esta registrada"));
          return;
        }
        final user = await _userRepository.getUser(infoAuthentication.userId);
        yield SuccessStream(user);
      case Fail():
        yield FailStream(response.error);
    }
  }
}
