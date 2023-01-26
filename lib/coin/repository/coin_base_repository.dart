import 'dart:core';

import 'package:lpcapital/coin/coin_network.dart';

abstract class CoinBaseRepository {
  Future<List<CoinNetwork>> getAll();
}
