part of '../library_page.dart';

class BarangUpdateScreen extends StatelessWidget {
  final BarangModel barang;
  final BarangController barangController = BarangController();
  BarangUpdateScreen({super.key, required this.barang}) {
    barangController.initForm(barang);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Barang')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: barangController.namaBarang,
                decoration: InputDecoration(
                  labelText: 'Nama Barang',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () => barangController.pickFile(context),
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Pilih File Barang',
                    prefixIcon: const Icon(Icons.attach_file),
                    suffixIcon: const Icon(Icons.file_upload_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: barangController.gambarBarang,
                    builder: (context, value, _) {
                      return Text(
                        value.text.isEmpty
                            ? 'Belum ada file dipilih'
                            : value.text.split('/').last,
                        style: TextStyle(
                          color: value.text.isEmpty
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: barangController.hargaBarang,
                decoration: InputDecoration(
                  labelText: 'Harga Barang',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: barangController.deskripsiBarang,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Barang',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  barangController.updateBarang(context, barang);
                },
                child: Text('Update Barang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
