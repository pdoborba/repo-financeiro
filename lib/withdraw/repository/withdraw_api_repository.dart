import 'package:dio/dio.dart';
import 'package:lpcapital/withdraw/withdraw.dart';

import '../../auth/auth_repository.dart';
import 'withdraw_base_repository.dart';

/// Do the communication with Withdraw API
class WithdrawApiRepository implements WithdrawBaseRepository {
  WithdrawApiRepository() : super();

  final AuthRepository authRepository = AuthRepository();

  @override
  Future<bool> withdrawBrl(String accountId, num value, num tax) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url = 'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com'
          '/prod/withdraws/brl';
      await dio.post(url,
          data: {
            'accountId': accountId,
            'amount': value,
            'tax': tax,
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
  Future<bool> withdrawCoin(String accountId, String asset, String network,
      num value, num tax) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url = 'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com'
          '/prod/withdraws/coin';
      await dio.post(url,
          data: {
            'accountId': accountId,
            'asset': asset,
            'network': network,
            'amount': value,
            'tax': tax,
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
  Future<List<Withdraw>> listWithdraws() async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var admin = user.email == 'admin@lpcapital.org.br';
      var token = await user.getIdToken();
      var url = admin == true
          ? 'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com'
              '/prod/withdraws/all'
          : 'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com'
              '/prod/withdraws';
      var response = await dio.post(url,
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return (response.data as List).map((i) => Withdraw.fromJson(i)).toList();
    } on DioError catch (_) {
      return [];
    } on Exception catch (_) {
      return [];
    } catch (fe) {
      return [];
    }
  }

  @override
  Future<bool> confirmWithdraw(String id) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/withdraws/confirm';
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
  Future<bool> cancelWithdraw(String id) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/withdraws/cancel';
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
