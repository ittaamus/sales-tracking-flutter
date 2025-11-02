import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Login related preferences
  static Future<void> setLoginStatus(bool isLoggedIn) async {
    await _preferences?.setBool('isLoggedIn', isLoggedIn);
  }

  static bool getLoginStatus() {
    return _preferences?.getBool('isLoggedIn') ?? false;
  }

  static Future<void> setUsername(String username) async {
    await _preferences?.setString('username', username);
  }

  static String getUsername() {
    return _preferences?.getString('username') ?? '';
  }

  static Future<void> setUserId(String userId) async {
    await _preferences?.setString('userId', userId);
  }

  static String getUserId() {
    return _preferences?.getString('userId') ?? '';
  }

  // User token if you're using JWT or similar
  static Future<void> setToken(String token) async {
    await _preferences?.setString('token', token);
  }

  static String getToken() {
    return _preferences?.getString('token') ?? '';
  }

  // Clear all user data on logout
  static Future<void> clearUserData() async {
    await _preferences?.remove('isLoggedIn');
    await _preferences?.remove('username');
    await _preferences?.remove('userId');
    await _preferences?.remove('token');
  }

  // Remember me functionality
  static Future<void> setRememberMe(bool rememberMe) async {
    await _preferences?.setBool('rememberMe', rememberMe);
  }

  static bool getRememberMe() {
    return _preferences?.getBool('rememberMe') ?? false;
  }

  // Save remembered credentials
  static Future<void> setRememberedCredentials(String username, String password) async {
    await _preferences?.setString('rememberedUsername', username);
    await _preferences?.setString('rememberedPassword', password);
  }

  static Map<String, String> getRememberedCredentials() {
    return {
      'username': _preferences?.getString('rememberedUsername') ?? '',
      'password': _preferences?.getString('rememberedPassword') ?? '',
    };
  }

  static Future<void> clearRememberedCredentials() async {
    await _preferences?.remove('rememberedUsername');
    await _preferences?.remove('rememberedPassword');
  }
}