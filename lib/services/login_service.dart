part of '../pages/library_page.dart';

class LoginService {
  Future<bool> login(LoginModel user) async {
    // debugPrint(user.uSERSNAME);
    // debugPrint(user.uSERSPASS);
    final url = Uri.parse("${BaseConfig.baseUrl}/users");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // cek apakah username dan password cocok
        final match = data.firstWhere(
          (item) =>
              item['USERS_NAME'] == user.uSERSNAME &&
              item['USERS_PASS'] == user.uSERSPASS,
          orElse: () => null,
        );
        if (match != null) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
