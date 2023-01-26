import 'dart:core';

import 'package:lpcapital/balance/balance.dart';

abstract class BalanceBaseRepository {
  Future<List<Balance>> loadBalance(String? asset);
}
