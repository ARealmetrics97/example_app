import 'package:example_app/domain/entities/info_authentication.dart';
import 'package:example_app/domain/entities/response.dart';
import 'package:example_app/domain/entities/user.dart';
import 'package:example_app/domain/errors/authentication_errors.dart';
import 'package:example_app/domain/errors/connection_errors.dart';
import 'package:example_app/domain/usecases/authentication_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:example_app/domain/repositories/auth_repository.dart';
import 'package:example_app/domain/repositories/user_repository.dart';
import 'package:mockito/mockito.dart';

import 'login_user_uc_test.mocks.dart';

@GenerateMocks([AuthRepository, UserRepository])
void main() {
  late MockAuthRepository authRepository;
  late MockUserRepository userRepository;
  late LoginUserUC loginUserUC;

  const isAFailUser = TypeMatcher<Fail<User>>();
  const isASuccess = TypeMatcher<Success<User>>();

  setUp(() {
    authRepository = MockAuthRepository();
    userRepository = MockUserRepository();
    loginUserUC = LoginUserUC(authRepository, userRepository);
  });

  test('test when email is empty', () async {
    //Arrange
    const email = "";
    const password = "123456";

    //Act
    final result = await loginUserUC.execute(email, password);

    //Asserts
    expect(result, isNotNull);
    expect(result, isAFailUser);
    expect((result as Fail<User>).error, isA<InvalidateCredentials>());
  });

  test('login test when password is empty', () async {
    //Arrange
    const email = "test@example.com";
    const password = "";

    //Act
    final result = await loginUserUC.execute(email, password);

    //Asserts
    expect(result, isNotNull);
    expect(result, isAFailUser);
    expect((result as Fail<User>).error, isA<InvalidateCredentials>());
  });

  test('login test when fail internet connection', () async {
    //Arrange
    const email = "test@example.com";
    const password = "12345";
    provideDummy<Response<InfoAuthentication>>(
        Fail<InfoAuthentication>(NetworkError("No internet connection")));
    when(authRepository.loginUser(email, password)).thenAnswer((_) =>
        Future.value(
            Fail<InfoAuthentication>(NetworkError("No internet connection"))));

    //Act
    final result = await loginUserUC.execute(email, password);

    //Asserts
    verify(authRepository.loginUser(email, password)).called(1);
    expect(result, isNotNull);
    expect(result, isAFailUser);
    expect((result as Fail<User>).error, isA<NetworkError>());
  });

  test('login test when email or password are not valid', () async {
    //Arrange
    const email = "test@example.com";
    const password = "12345";
    provideDummy<Response<InfoAuthentication>>(Fail<InfoAuthentication>(
        InvalidateCredentials("Email and password are not valid")));
    when(authRepository.loginUser(email, password)).thenAnswer((_) =>
        Future.value(Fail<InfoAuthentication>(
            InvalidateCredentials("Email and password are not valid"))));

    //Act
    final result = await loginUserUC.execute(email, password);

    //Asserts
    verify(authRepository.loginUser(email, password)).called(1);
    expect(result, isNotNull);
    expect(result, isAFailUser);
    expect((result as Fail<User>).error, isA<InvalidateCredentials>());
  });

  test('login test when user not exists in DB', () async {
    //Arrange
    const email = "test@example.com";
    const password = "12345";
    final infoAuthentication = InfoAuthentication(email, password);
    provideDummy<Response<InfoAuthentication>>(
        Success<InfoAuthentication>(infoAuthentication));
    when(authRepository.loginUser(email, password)).thenAnswer(
        (_) => Future.value(Success<InfoAuthentication>(infoAuthentication)));
    when(userRepository.verifyUserExists(infoAuthentication.userId))
        .thenAnswer((_) => Future.value(false));

    //Act
    final result = await loginUserUC.execute(email, password);

    //Asserts
    verify(authRepository.loginUser(email, password)).called(1);
    verify(userRepository.verifyUserExists(infoAuthentication.userId))
        .called(1);
    expect(result, isNotNull);
    expect(result, isAFailUser);
    expect((result as Fail<User>).error, isA<AccountNotSignIn>());
  });

  test('login test when user exists in DB', () async {
    //Arrange
    const email = "test@example.com";
    const password = "12345";
    final infoAuthentication = InfoAuthentication(email, password);
    final user =
        User("ABCDEFGHIJ", email, password, "Name Last_Name Second_Last_Name");
    provideDummy<Response<InfoAuthentication>>(
        Success<InfoAuthentication>(infoAuthentication));
    when(authRepository.loginUser(email, password)).thenAnswer(
        (_) => Future.value(Success<InfoAuthentication>(infoAuthentication)));
    when(userRepository.verifyUserExists(infoAuthentication.userId))
        .thenAnswer((_) => Future.value(true));
    when(userRepository.getUser(infoAuthentication.userId))
        .thenAnswer((_) => Future.value(user));

    //Act
    final result = await loginUserUC.execute(email, password);

    //Asserts
    verify(authRepository.loginUser(email, password)).called(1);
    verify(userRepository.verifyUserExists(infoAuthentication.userId))
        .called(1);
    verify(userRepository.getUser(infoAuthentication.userId)).called(1);
    expect(result, isNotNull);
    expect(result, isASuccess);
    expect((result as Success<User>).value, user);
  });
}
