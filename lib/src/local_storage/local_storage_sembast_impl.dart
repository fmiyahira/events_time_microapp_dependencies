import 'package:events_time_microapp_dependencies/src/local_storage/local_storage.dart';
import 'package:sembast/sembast.dart';

class LocalStorageSembastImpl implements ILocalStorage {
  final Database db;
  final StoreRef<Object?, Object?> store = StoreRef<Object?, Object?>.main();

  LocalStorageSembastImpl(this.db);

  @override
  Future<bool> setString(String key, String value) async {
    try {
      await store.record(key).put(db, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return await store.record(key).get(db) as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      await store.record(key).put(db, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return await store.record(key).get(db) as int?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      await store.record(key).put(db, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      return await store.record(key).get(db) as double?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      await store.record(key).put(db, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return await store.record(key).get(db) as bool?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool?> delete(String key) async {
    try {
      await store.record(key).delete(db);
      return true;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool?> deleteAll() async {
    try {
      await store.delete(db);
      return true;
    } catch (_) {
      return null;
    }
  }
}
