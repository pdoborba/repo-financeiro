import 'package:dio/dio.dart';
import 'package:lpcapital/account/account.dart';

import '../../auth/auth_repository.dart';
import 'account_base_repository.dart';

/// Do the communication with Account API
class AccountApiRepository implements AccountBaseRepository {
  AccountApiRepository() : super();

  final AuthRepository authRepository = AuthRepository();

  @override
  Future<Account?> createAccount(Account account) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/accounts';
      var response = await dio.post(url,
          data: {
            'bank': account.bank,
            'agency': account.agency,
            'cc': account.cc,
            'pixType': account.pixType,
            'pix': account.pix,
            'type': account.type,
            'link': account.link,
          },
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return Account.fromJson(response.data);
    } on DioError catch (_) {
      return null;
    } on Exception catch (_) {
      return null;
    } catch (fe) {
      return null;
    }
  }

  ///Return balances
  @override
  Future<Account?> editAccount(Account account) async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/accounts';
      var response = await dio.put(url,
          data: {
            'id': account.id,
            'email': account.email,
            'bank': account.bank,
            'agency': account.agency,
            'cc': account.cc,
            'pixType': account.pixType,
            'pix': account.pix,
            'type': account.type,
            'link': account.link,
            'createdAt': account.createdAt,
            'updatedAt': account.updatedAt,
          },
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return Account.fromJson(response.data);
    } on DioError catch (_) {
      return null;
    } on Exception catch (_) {
      return null;
    } catch (fe) {
      return null;
    }
  }

  @override
  Future<List<Account>> listAccounts() async {
    try {
      final Dio dio = Dio();
      var user = authRepository.getUser()!;
      var token = await user.getIdToken();
      var url =
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/accounts';
      var response = await dio.get(url,
          options: Options(headers: {'authorization': 'Bearer $token'}));
      return (response.data as List).map((i) => Account.fromJson(i)).toList();
    } on DioError catch (e) {
      print(e);
      return [];
    } on Exception catch (de) {
      print(de);
      return [];
    }
  }
}
