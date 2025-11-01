part of '../pages/library_page.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginService _loginService = LoginService();

  Future<bool> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    LoginModel user = LoginModel(uSERSNAME: username, uSERSPASS: password);

    return await _loginService.login(user);
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
