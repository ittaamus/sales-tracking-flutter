class CustomerModel {
  String? cUSTOMERID;
  String? cUSTOMERNAME;
  String? cUSTOMEREMAIL;
  String? cUSTOMERALAMAT;

  CustomerModel(
      {this.cUSTOMERID,
      this.cUSTOMERNAME,
      this.cUSTOMEREMAIL,
      this.cUSTOMERALAMAT});

  CustomerModel.fromJson(Map<String, dynamic> json) {
    cUSTOMERID = json['CUSTOMER_ID'];
    cUSTOMERNAME = json['CUSTOMER_NAME'];
    cUSTOMEREMAIL = json['CUSTOMER_EMAIL'];
    cUSTOMERALAMAT = json['CUSTOMER_ALAMAT'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CUSTOMER_ID'] = this.cUSTOMERID;
    data['CUSTOMER_NAME'] = this.cUSTOMERNAME;
    data['CUSTOMER_EMAIL'] = this.cUSTOMEREMAIL;
    data['CUSTOMER_ALAMAT'] = this.cUSTOMERALAMAT;
    return data;
  }
}