import 'dart:core';

import '../history.dart';

abstract class HistoryBaseRepository {
  Future<History?> loadHistory();
}
