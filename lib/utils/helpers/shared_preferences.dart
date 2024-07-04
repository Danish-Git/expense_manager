import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  Future<String?>? read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  removeAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}