import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loginKey = 'isLoggedIn';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'useEmail';

  Future<void> saveUserData(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, true);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String name = prefs.getString(_userNameKey) ?? 'CineScope User';
    String email = prefs.getString(_userEmailKey) ?? 'user@example.com';
    return {'name' : name, 'email' : email};
  }
}