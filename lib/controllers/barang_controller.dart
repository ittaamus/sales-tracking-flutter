part of '../pages/library_page.dart';

class BarangController {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController namaBarang = TextEditingController();
  final TextEditingController gambarBarang = TextEditingController();
  final TextEditingController hargaBarang = TextEditingController();
  final TextEditingController deskripsiBarang = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<List<BarangModel>> barangList = ValueNotifier([]);
  Future<List<BarangModel>>? filteredBarangList;
  String? pickedFilePath;

  Future<List<BarangModel>> getAllBarang() {
    return Barangservices().getAllBarang();
  }

  Future<void> reloadData() async {
    final data = await Barangservices().getAllBarang();
    barangList.value = data; // ini akan trigger rebuild di UI
  }

  Future<bool> deleteBarang(
    String id,
    BuildContext context,
    String name,
  ) async {
    try {
      final success = await Barangservices().deleteBarang(id);

      if (success) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> simpanDataBarang(BuildContext context) async {
    final String setnama = namaBarang.text;
    final String setgambar = gambarBarang.text;
    final String setharga = hargaBarang.text;
    final String setdeskripsi = deskripsiBarang.text;
    try {
      final barang = BarangModel(
        bARANGNAME: setnama,
        bARANGIMAGE: setgambar,
        bARANGPRICE: setharga,
        bARANGDESC: setdeskripsi,
      );
      final file = pickedFilePath != null ? File(pickedFilePath!) : null;
      await Barangservices().insertBarang(barang, file);
      return true;
    } catch (e) {
      debugPrint('Error simpanDataBarang: $e');
      return false;
    }
  }

  bool isSaving = false;
  void initForm(BarangModel barang) {
    namaBarang.text = barang.bARANGNAME ?? '';
    gambarBarang.text = barang.bARANGIMAGE ?? '';
    deskripsiBarang.text = barang.bARANGDESC ?? '';
    hargaBarang.text = barang.bARANGPRICE ?? '';
  }

  Future<bool> updateBarang(BuildContext context, BarangModel barang) async {
    final String setnama = namaBarang.text;
    final String setgambar = gambarBarang.text;
    final String setharga = hargaBarang.text;
    final String setdeskripsi = deskripsiBarang.text;
    try {
      final barang = BarangModel(
        bARANGNAME: setnama,
        bARANGIMAGE: setgambar,
        bARANGPRICE: setharga,
        bARANGDESC: setdeskripsi,
      );
      final file = pickedFilePath != null ? File(pickedFilePath!) : null;
      await Barangservices().updateBarang(barang, file);
      return true;
    } catch (e) {
      debugPrint('Error simpanDataBarang: $e');
      return false;
    }
  }

  void dispose() {
    namaBarang.dispose();
    gambarBarang.dispose();
    hargaBarang.dispose();
    deskripsiBarang.dispose();
  }

  void searchBarang() {
    final keyword = searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) {
      reloadData();
    } else {
      final filtered = barangList.value
          .where(
            (item) => (item.bARANGNAME ?? '').toLowerCase().contains(
              keyword.toLowerCase(),
            ),
          )
          .toList();
      barangList.value = filtered; // trigger rebuild di UI
    }
  }

  Future<void> pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      gambarBarang.text = file.name;
      pickedFilePath = file.path; // simpan path file
      debugPrint('Nama file dipilih: ${file.name}');
    }
  }
}
