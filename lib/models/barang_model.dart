class BarangModel {
  String? bARANGID;
  String? bARANGNAME;
  String? bARANGIMAGE;
  String? bARANGPRICE;
  String? bARANGDESC;

  BarangModel({
    this.bARANGID,
    this.bARANGNAME,
    this.bARANGIMAGE,
    this.bARANGPRICE,
    this.bARANGDESC,
  });

  BarangModel.fromJson(Map<String, dynamic> json) {
    bARANGID = json['BARANG_ID'];
    bARANGNAME = json['BARANG_NAME'];
    bARANGIMAGE = json['BARANG_IMAGE'];
    bARANGPRICE = json['BARANG_PRICE'];
    bARANGDESC = json['BARANG_DESC'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['BARANG_ID'] = bARANGID;
    data['BARANG_NAME'] = bARANGNAME;
    data['BARANG_IMAGE'] = bARANGIMAGE;
    data['BARANG_PRICE'] = bARANGPRICE;
    data['BARANG_DESC'] = bARANGDESC;
    return data;
  }
}
