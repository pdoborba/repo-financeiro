import 'package:dio/dio.dart';

import '../../auth/auth_repository.dart';
import '../deposit.dart';
import 'deposit_base_repository.dart';

/// Do the communication with Deposit API
class DepositApiRepository implements DepositBaseRepository {
  DepositApiRepository() : super();

  final AuthRepository authRepository = AuthRepository();

  ///Return balances
  @override
  Future<bool> createDeposit(num amount, String asset, String type) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/deposits';
      await dio.post(url,
          data: {
            'amount': amount,
            'asset': asset,
            'type': type,
          },
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return true;
    } on DioError catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    } catch (fe) {
      return false;
      ;
    }
  }

  @override
  Future<List<Deposit>> listDeposits() async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var admin = user.email == 'admin@lpcapital.org.br';
      var url = admin == true
          ? 'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com'
              '/prod/deposits/all'
          : 'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com'
              '/prod/deposits';
      var response = await dio.post(url,
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return (response.data as List).map((i) => Deposit.fromJson(i)).toList();
    } on DioError catch (e) {
      return [];
    } on Exception catch (e1) {
      return [];
    } catch (fe) {
      return [];
    }
  }

  @override
  Future<bool> confirmDeposit(String id) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/deposits/confirm';
      await dio.post(url,
          data: {
            'id': id,
          },
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return true;
    } on DioError catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    } catch (fe) {
      return false;
    }
  }

  @override
  Future<bool> cancelDeposit(String id) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/deposits/cancel';
      await dio.post(url,
          data: {
            'id': id,
          },
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return true;
    } on DioError catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    } catch (fe) {
      return false;
    }
  }
}
