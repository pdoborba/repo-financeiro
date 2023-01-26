import 'dart:core';

import 'package:lpcapital/account/account.dart';

import 'account_api_repository.dart';
import 'account_base_repository.dart';

class AccountRepository implements AccountBaseRepository {
  final AccountBaseRepository apiClient;

  AccountRepository() : apiClient = AccountApiRepository();

  @override
  Future<Account?> createAccount(Account account) {
    return apiClient.createAccount(account);
  }

  @override
  Future<Account?> editAccount(Account account) {
    return apiClient.editAccount(account);
  }

  @override
  Future<List<Account>> listAccounts() {
    return apiClient.listAccounts();
  }
}
