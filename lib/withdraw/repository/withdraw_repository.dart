import 'dart:core';

import 'package:lpcapital/withdraw/withdraw.dart';

import 'withdraw_api_repository.dart';
import 'withdraw_base_repository.dart';

class WithdrawRepository implements WithdrawBaseRepository {
  final WithdrawBaseRepository apiClient;

  WithdrawRepository() : apiClient = WithdrawApiRepository();

  @override
  Future<bool> withdrawBrl(String accountId, num value, num tax) {
    return apiClient.withdrawBrl(accountId, value, tax);
  }

  @override
  Future<bool> withdrawCoin(
      String accountId, String asset, String network, num value, num tax) {
    return apiClient.withdrawCoin(accountId, asset, network, value, tax);
  }

  @override
  Future<List<Withdraw>> listWithdraws() {
    return apiClient.listWithdraws();
  }

  @override
  Future<bool> confirmWithdraw(String id) {
    return apiClient.confirmWithdraw(id);
  }

  @override
  Future<bool> cancelWithdraw(String id) {
    return apiClient.cancelWithdraw(id);
  }
}
