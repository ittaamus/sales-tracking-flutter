part of '../library_page.dart';

class VisitScreen extends StatelessWidget {
  VisitScreen({super.key});
  final VisitController visitController = VisitController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kunjungan Barang')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.pushNamed(context, '/addVisit');
          if (added == true) visitController.loadData();  
          
          // final added = await Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => BarangAddScreen()),
          // );
          // if (added == true) barangController.reloadData();
        },
        label: const Text('Add Kunjungan'),
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
                    controller: visitController.searchController,
                    onChanged: (_) => visitController
                        .searchVisit(), //ini kalo mau search keypress
                    decoration: InputDecoration(
                      labelText: 'Cari Kunjungan',
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
                    // visitController.searchCustomer();
                  },
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Cari'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<VisitModel>>(
              valueListenable: visitController.visitList,
              builder: (context, data, _) {
                if (data.isEmpty) {
                  return const Center(child: Text('No Data Available'));
                }
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final visit = data[index];
                    return Dismissible(
                      key: ValueKey(visit.vISITID ?? index),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        final success = await visitController.deleteVisit(
                          visit.vISITID ?? '',
                          context,
                          visit.vISITSALESID ?? '',
                        );
                        if (!context.mounted) return;
                        if (success) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Sukses'),
                                content: Text(
                                  '${visit.vISITCUSTID} berhasil dihapus!',
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
                                'Gagal menghapus ${visit.vISITCUSTID}',
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
                            '/updateVisit',
                            arguments: visit,
                          ).then((updated) {
                            if (updated == true) {
                              visitController.loadData();
                            }
                          });
                        },
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: visit.vISITCUSTID != null
                                  ? Image.network(
                                      visit.iMAGESURL!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(visit.vISITCUSTID ?? ''),
                          subtitle: Text(visit.nOTES ?? 'No Description'),
                          trailing: Text(visit.vISITSALESID ?? 'No Price'),
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
