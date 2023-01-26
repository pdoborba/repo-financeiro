import 'dart:core';

import '../deposit.dart';

abstract class DepositBaseRepository {
  Future<bool> createDeposit(num amount, String asset, String type);
  Future<bool> confirmDeposit(String id);
  Future<bool> cancelDeposit(String id);
  Future<List<Deposit>> listDeposits();
}
