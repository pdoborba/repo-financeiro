import 'dart:core';

import 'package:lpcapital/coin/coin_network.dart';

import 'coin_api_repository.dart';
import 'coin_base_repository.dart';

/// A balance that glues together our local file storage (not yet) and api client
class CoinRepository implements CoinBaseRepository {
  final CoinBaseRepository apiClient;

  CoinRepository() : apiClient = CoinApiRepository();

  @override
  Future<List<CoinNetwork>> getAll() {
    return apiClient.getAll();
  }
}
