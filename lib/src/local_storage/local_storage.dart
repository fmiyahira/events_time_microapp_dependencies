abstract class ILocalStorage {
  Future<bool> setString(String key, String value);
  Future<String?> getString(String key);

  Future<bool> setInt(String key, int value);
  Future<int?> getInt(String key);

  Future<bool> setDouble(String key, double value);
  Future<double?> getDouble(String key);

  Future<bool> setBool(String key, bool value);
  Future<bool?> getBool(String key);

  Future<bool?> delete(String key);
  Future<bool?> deleteAll();
}
