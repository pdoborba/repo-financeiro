import 'dart:core';

import 'package:lpcapital/deposit/deposit.dart';

import 'deposit_api_repository.dart';
import 'deposit_base_repository.dart';

/// A balance that glues together our local file storage (not yet) and api client
class DepositRepository implements DepositBaseRepository {
  final DepositBaseRepository apiClient;

  DepositRepository() : apiClient = DepositApiRepository();

  @override
  Future<bool> createDeposit(num amount, String asset, String type) {
    return apiClient.createDeposit(amount, asset, type);
  }

  @override
  Future<List<Deposit>> listDeposits() {
    return apiClient.listDeposits();
  }

  @override
  Future<bool> confirmDeposit(String id) {
    return apiClient.confirmDeposit(id);
  }

  @override
  Future<bool> cancelDeposit(String id) {
    return apiClient.cancelDeposit(id);
  }
}
