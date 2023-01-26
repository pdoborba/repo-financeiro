import 'dart:core';

import '../user.dart';

abstract class UserBaseRepository {
  Future<List<User>> listUsers();
}
