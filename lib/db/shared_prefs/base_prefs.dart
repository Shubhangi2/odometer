import 'package:shared_preferences/shared_preferences.dart';

class BasePrefs {
  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    final prefs = await getPrefs();
    await prefs.setString(key, value);
  }

  Future<String> getString(String key) async {
    final prefs = await getPrefs();
    return prefs.getString(key) ?? "";
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await getPrefs();
    await prefs.setBool(key, value);
  }

  Future<bool> getBool(String key) async {
    final prefs = await getPrefs();
    return prefs.getBool(key) ?? false;
  }

  Future<void> clearPrefs() async {
    final prefs = await getPrefs();
    prefs.clear();
  }
}
