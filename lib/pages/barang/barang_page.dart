part of '../library_page.dart';

class BarangScreen extends StatelessWidget {
  BarangScreen({super.key});

  final BarangController barangController = BarangController();

  @override
  Widget build(BuildContext context) {
    barangController.reloadData();
    return Scaffold(
      appBar: AppBar(title: const Text('Barang')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BarangAddScreen()),
          );
          if (added == true) barangController.reloadData();
        },
        label: const Text('Add Barang'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // TextField untuk input pencarian
                Expanded(
                  child: TextField(
                    controller: barangController.searchController,
                    onChanged: (_) => barangController
                        .searchBarang(), //ini kalo mau search keypress
                    decoration: InputDecoration(
                      labelText: 'Cari Barang',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Cari
                ElevatedButton.icon(
                  onPressed: () async {
                    barangController.searchBarang();
                  },
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Cari'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<BarangModel>>(
              valueListenable: barangController.barangList,
              builder: (context, data, _) {
                if (data.isEmpty) {
                  return const Center(child: Text('No Data Available'));
                }
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final barang = data[index];
                    return Dismissible(
                      key: ValueKey(barang.bARANGID ?? index),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        final success = await barangController.deleteBarang(
                          barang.bARANGID ?? '',
                          context,
                          barang.bARANGNAME ?? '',
                        );
                        if (!context.mounted) return;
                        if (success) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Sukses'),
                                content: Text(
                                  '${barang.bARANGNAME} berhasil dihapus!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pop(); // Tutup dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gagal menghapus ${barang.bARANGNAME}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },

                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pushNamed(
                            context,
                            '/updateBarang',
                            arguments: barang,
                          ).then((updated) {
                            if (updated == true) {
                              barangController.reloadData();
                            }
                          });
                        },
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: barang.bARANGIMAGE != null
                                  ? Image.network(
                                      barang.bARANGIMAGE!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(barang.bARANGNAME ?? ''),
                          subtitle: Text(barang.bARANGDESC ?? 'No Description'),
                          trailing: Text(barang.bARANGPRICE ?? 'No Price'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
