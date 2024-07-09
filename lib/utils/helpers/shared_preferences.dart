import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  ///   [read] method is used to read data from shared preferences
  Future<String?>? read (String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  ///   [save] method is used to save the data in shared preferences
  save (String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  ///   [removeAll] method is used to clear all records from the shared preferences
  removeAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}