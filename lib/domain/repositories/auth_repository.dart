import 'package:example_app/domain/entities/info_authentication.dart';
import 'package:example_app/domain/entities/response.dart';

abstract class AuthRepository {
  Future<Response<InfoAuthentication>> loginUser(String email, String password);
}
