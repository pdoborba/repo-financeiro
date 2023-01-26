import 'package:dio/dio.dart';
import 'package:lpcapital/coin/coin_network.dart';

import '../../auth/auth_repository.dart';
import 'coin_base_repository.dart';

/// Do the communication with Coin API
class CoinApiRepository implements CoinBaseRepository {
  CoinApiRepository() : super();

  final AuthRepository authRepository = AuthRepository();

  @override
  Future<List<CoinNetwork>> getAll() async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url = 'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com'
          '/prod/coins/all';
      var response = await dio.get(url,
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return (response.data as List)
          .map((i) => CoinNetwork.fromJson(i))
          .toList();
    } on DioError catch (_) {
      return [];
    } on Exception catch (_) {
      return [];
    } catch (fe) {
      return [];
    }
  }
}
