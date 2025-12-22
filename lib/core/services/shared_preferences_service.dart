import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences instance
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Ensure preferences is initialized
  static SharedPreferences get _prefs {
    if (_preferences == null) {
      throw Exception(
        'SharedPreferencesService not initialized. Call init() first.',
      );
    }
    return _preferences!;
  }

  // String operations
  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  // Int operations
  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Bool operations
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // StringList operations
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // Remove a key
  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all data
  static Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  static Set<String> getKeys() {
    return _prefs.getKeys();
  }
}
