import 'package:example_app/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> saveUser(User user);
  Future<bool> verifyUserExists(String userId);
  Future<User> getUser(String userId);
}
