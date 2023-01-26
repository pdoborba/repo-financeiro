import 'dart:core';

import '../balance.dart';
import 'balance_api_repository.dart';
import 'balance_base_repository.dart';

/// A balance that glues together our local file storage (not yet) and api client
class BalanceRepository implements BalanceBaseRepository {
  final BalanceBaseRepository apiClient;

  BalanceRepository() : apiClient = BalanceApiRepository();

  @override
  Future<List<Balance>> loadBalance(String? asset) {
    return apiClient.loadBalance(asset);
  }
}
