import 'package:dio/dio.dart';

import '../../../auth/auth_repository.dart';
import '../user.dart';
import 'user_base_repository.dart';

/// Do the communication with User API
class UserApiRepository implements UserBaseRepository {
  UserApiRepository() : super();

  final AuthRepository authRepository = AuthRepository();

  @override
  Future<List<User>> listUsers() async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/users';
      var response = await dio.get(url,
          options: Options(headers: {'authorization': 'Bearer $token'}));
      print(response.data);
      return (response.data as List).map((i) => User.fromJson(i)).toList();
    } on DioError catch (de) {
      print(de);
      return [];
    } on Exception catch (e) {
      print(e);
      return [];
    } catch (fe) {
      print(fe);
      return [];
    }
  }
}
