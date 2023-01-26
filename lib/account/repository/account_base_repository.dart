import 'dart:core';

import 'package:lpcapital/account/account.dart';

abstract class AccountBaseRepository {
  Future<Account?> createAccount(Account account);
  Future<Account?> editAccount(Account account);
  Future<List<Account>> listAccounts();
}
