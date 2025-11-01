part of '../pages/library_page.dart';

class Barangservices {
  final String url = "${BaseConfig.baseUrl}/barang";

  Future<List<BarangModel>> getAllBarang() async {
    // debugPrint('GET barang @ ${DateTime.now()}');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<BarangModel> barang = data
          .map((dynamic item) => BarangModel.fromJson(item))
          .toList();
      // for (var b in barang) {
      //   debugPrint(b.toJson().toString());
      // }
      return barang;
    } else {
      throw 'Failed to load Barang List';
    }
  }

  //insert
  Future<bool> insertBarang(BarangModel barang, File? imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Tambahkan field teks
      request.fields['BARANG_NAME'] = barang.bARANGNAME ?? '';
      request.fields['BARANG_PRICE'] = barang.bARANGPRICE ?? '';
      request.fields['BARANG_DESC'] = barang.bARANGDESC ?? '';

      // Tambahkan file kalau ada
      if (imageFile != null) {
        final fileStream = await http.MultipartFile.fromPath(
          'BARANG_IMAGE',
          imageFile.path,
        );
        request.files.add(fileStream);
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        debugPrint('Barang berhasil ditambahkan: $body');
        return true;
      } else {
        debugPrint('Gagal tambah Barang: ${response.statusCode} => $body');
        return false;
      }
    } catch (e) {
      debugPrint('Error insertBarang: $e');
      return false;
    }
  }

  //delete
  Future<bool> deleteBarang(String id) async {
    try {
      final response = await http.delete(Uri.parse('$url/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Barang $id berhasil dihapus');
        return true;
      } else {
        debugPrint('Gagal hapus Barang: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleteBarang: $e');
      return false;
    }
  }

  //update service
  Future<bool> updateBarang(BarangModel barang, File? imageFile) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$url/${barang.bARANGID}'),
      );

      // Tambahkan field teks
      request.fields['BARANG_NAME'] = barang.bARANGNAME ?? '';
      request.fields['BARANG_PRICE'] = barang.bARANGPRICE ?? '';
      request.fields['BARANG_DESC'] = barang.bARANGDESC ?? '';

      // Tambahkan file kalau ada
      if (imageFile != null) {
        final fileStream = await http.MultipartFile.fromPath(
          'BARANG_IMAGE',
          imageFile.path,
        );
        request.files.add(fileStream);
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        debugPrint('Barang berhasil ditambahkan: $body');
        return true;
      } else {
        debugPrint('Gagal tambah Barang: ${response.statusCode} => $body');
        return false;
      }
    } catch (e) {
      debugPrint('Error insertBarang: $e');
      return false;
    }
  }
}
