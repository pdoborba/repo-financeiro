import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_repository.dart';
import '../balance.dart';
import 'balance_base_repository.dart';

/// Do the communication with Balance API
class BalanceApiRepository implements BalanceBaseRepository {
  BalanceApiRepository() : super();

  final AuthRepository authRepository = AuthRepository();

  ///Return balances
  @override
  Future<List<Balance>> loadBalance(String? asset) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken(true);
      print(token.length);
      debugPrint(token.substring(0, 1000));
      debugPrint(token.substring(1000, 1441));
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/balance';
      if (asset != null && asset.isNotEmpty) {
        url = '$url?asset=$asset';
      }
      var response = await dio.post(url,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return (response.data as List).map((i) => Balance.fromJson(i)).toList();
    } on DioError catch (e) {
      print('dio $e');
      return [];
    } on Exception catch (ge) {
      print('ge $ge');
      return [];
    } catch (fe) {
      return [];
    }
  }
}
