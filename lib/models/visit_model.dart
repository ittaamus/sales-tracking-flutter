class VisitModel {
  String? vISITID;
  String? vISITSALESID;
  String? vISITCUSTID;
  String? vISITTIME;
  String? lATITUDE;
  String? lONGITUDE;
  String? iMAGESURL;
  String? nOTES;

  VisitModel({
    this.vISITID,
    this.vISITSALESID,
    this.vISITCUSTID,
    this.vISITTIME,
    this.lATITUDE,
    this.lONGITUDE,
    this.iMAGESURL,
    this.nOTES,
  });

  VisitModel.fromJson(Map<String, dynamic> json) {
    vISITID = json['VISIT_ID'];
    vISITSALESID = json['VISIT_SALES_ID'];
    vISITCUSTID = json['VISIT_CUST_ID'];
    vISITTIME = json['VISIT_TIME'];
    lATITUDE = json['LATITUDE'];
    lONGITUDE = json['LONGITUDE'];
    iMAGESURL = json['IMAGES_URL'];
    nOTES = json['NOTES'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['VISIT_ID'] = vISITID;
    data['VISIT_SALES_ID'] = vISITSALESID;
    data['VISIT_CUST_ID'] = vISITCUSTID;
    data['VISIT_TIME'] = vISITTIME;
    data['LATITUDE'] = lATITUDE;
    data['LONGITUDE'] = lONGITUDE;
    data['IMAGES_URL'] = iMAGESURL;
    data['NOTES'] = nOTES;
    return data;
  }
}
