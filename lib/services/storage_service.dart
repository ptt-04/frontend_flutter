import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService chưa được khởi tạo');
    }
    return _prefs!;
  }

  // Auth related
  static Future<void> saveAuthToken(String token) async {
    await prefs.setString('auth_token', token);
  }

  static String? getAuthToken() {
    return prefs.getString('auth_token');
  }

  static Future<void> removeAuthToken() async {
    await prefs.remove('auth_token');
  }

  // User preferences
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await prefs.setString('user_data', userData.toString());
  }

  static Map<String, dynamic>? getUserData() {
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      // Parse the string back to Map
      // This is a simplified implementation
      return {};
    }
    return null;
  }

  static Future<void> clearUserData() async {
    await prefs.remove('user_data');
  }

  // App settings
  static Future<void> setThemeMode(String mode) async {
    await prefs.setString('theme_mode', mode);
  }

  static String getThemeMode() {
    return prefs.getString('theme_mode') ?? 'system';
  }

  static Future<void> setLanguage(String language) async {
    await prefs.setString('language', language);
  }

  static String getLanguage() {
    return prefs.getString('language') ?? 'vi';
  }

  // Clear all data
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}





