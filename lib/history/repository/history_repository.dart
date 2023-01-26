import 'dart:core';

import '../history.dart';
import 'history_api_repository.dart';
import 'history_base_repository.dart';

/// A balance that glues together our local file storage (not yet) and api client
class HistoryRepository implements HistoryBaseRepository {
  final HistoryBaseRepository apiClient;

  HistoryRepository() : apiClient = HistoryApiRepository();

  @override
  Future<History?> loadHistory() {
    return apiClient.loadHistory();
  }
}
