part of '../pages/library_page.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  bool rememberMe = false;

  LoginController() {
    _loadRememberedCredentials();
  }

  // Load remembered credentials if "Remember Me" was checked
  void _loadRememberedCredentials() {
    if (SharedPreferencesService.getRememberMe()) {
      final credentials = SharedPreferencesService.getRememberedCredentials();
      usernameController.text = credentials['username'] ?? '';
      passwordController.text = credentials['password'] ?? '';
      rememberMe = true;
    }
  }

  Future<bool> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    LoginModel user = LoginModel(uSERSNAME: username, uSERSPASS: password);

    bool loginSuccess = await _loginService.login(user);

    if (loginSuccess) {
      // Save login status
      await SharedPreferencesService.setLoginStatus(true);
      await SharedPreferencesService.setUsername(username);

      // Save credentials if remember me is checked
      if (rememberMe) {
        await SharedPreferencesService.setRememberMe(true);
        await SharedPreferencesService.setRememberedCredentials(
          username,
          password,
        );
      } else {
        await SharedPreferencesService.setRememberMe(false);
        await SharedPreferencesService.clearRememberedCredentials();
      }
    }

    return loginSuccess;
  }

  Future<void> logout() async {
    await SharedPreferencesService.clearUserData();
  }

  bool isLoggedIn() {
    return SharedPreferencesService.getLoginStatus();
  }

  String getCurrentUsername() {
    return SharedPreferencesService.getUsername();
  }

  void setRememberMe(bool value) {
    rememberMe = value;
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
