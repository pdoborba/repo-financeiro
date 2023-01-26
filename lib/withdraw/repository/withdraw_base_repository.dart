import 'dart:core';

import 'package:lpcapital/withdraw/withdraw.dart';

abstract class WithdrawBaseRepository {
  Future<bool> withdrawBrl(String accountId, num value, num tax);
  Future<bool> withdrawCoin(
      String accountId, String asset, String network, num value, num tax);
  Future<List<Withdraw>> listWithdraws();
  Future<bool> confirmWithdraw(String id);
  Future<bool> cancelWithdraw(String id);
}
