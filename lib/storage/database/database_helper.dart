import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../storage_repository.dart';

class DatabaseHelper with StorageRepository {
  bool isInitialized = false;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  Future<void> get database async {
    if (!isInitialized) {
      await _initDatabase();
    }
    isInitialized = true;
  }

  Future<List<int>> getKey() async {
    var key = await (getAppBaseKey());
    return key!.codeUnits;
  }

  // open the database
  Future<void> _initDatabase() async {
    await Hive.initFlutter();
    var appBaseKey = Hive.generateSecureKey();
    var existingBaseKey = await (getAppBaseKey());
    if (existingBaseKey == null || existingBaseKey.isEmpty) {
      await setAppBaseKey(String.fromCharCodes(appBaseKey));
    }
  }

  // clean the database
  Future<void> cleanDatabase() async {}
}
