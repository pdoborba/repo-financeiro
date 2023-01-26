import 'dart:core';

import '../user.dart';
import 'user_api_repository.dart';
import 'user_base_repository.dart';

class UserRepository implements UserBaseRepository {
  final UserBaseRepository apiClient;

  UserRepository() : apiClient = UserApiRepository();

  @override
  Future<List<User>> listUsers() {
    return apiClient.listUsers();
  }
}
