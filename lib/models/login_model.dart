class LoginModel {
  String? uSERSID;
  String? uSERSNAME;
  String? uSERSPASS;

  LoginModel({this.uSERSID, this.uSERSNAME, this.uSERSPASS});

  LoginModel.fromJson(Map<String, dynamic> json) {
    uSERSID = json['USERS_ID'];
    uSERSNAME = json['USERS_NAME'];
    uSERSPASS = json['USERS_PASS'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['USERS_ID'] = uSERSID;
    data['USERS_NAME'] = uSERSNAME;
    data['USERS_PASS'] = uSERSPASS;
    return data;
  }
}
