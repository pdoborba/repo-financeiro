import 'package:dio/dio.dart';

import '../../auth/auth_repository.dart';
import '../history.dart';
import 'history_base_repository.dart';

/// Do the communication with History API
class HistoryApiRepository implements HistoryBaseRepository {
  HistoryApiRepository() : super();

  final AuthRepository authRepository = AuthRepository();

  ///Return balances
  @override
  Future<History?> loadHistory() async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/balance/extract';
      var response = await dio.post(url,
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return History.fromJson(response.data);
    } on DioError catch (de) {
      return null;
    } on Exception catch (e) {
      return null;
    } catch (fe) {
      return null;
    }
  }
}
