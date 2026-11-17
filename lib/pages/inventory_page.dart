
import 'detail_item_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'add_item_page.dart';
import 'edit_item_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirestoreService firestoreService = FirestoreService();

  // MENGHAPUS DATA
  Future<void> deleteItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alat'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus alat ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await firestoreService.deleteItem(itemId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus!'),
        ),
      );
    }
  }

  // MEMINJAM ALAT
  Future<void> borrowItem(
    String itemId,
    String itemName,
  ) async {
    try {
      await firestoreService.borrowItem(
        itemId: itemId,
        itemName: itemName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alat berhasil dipinjam!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal meminjam alat: $e')),
      );
    }
  }

  // MENGEMBALIKAN ALAT
  Future<void> returnItem(String itemId) async {
    try {
      await firestoreService.returnItem(itemId: itemId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alat berhasil dikembalikan!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengembalikan alat: $e')),
      );
    }
  }

  // MENAMPILKAN GAMBAR
  Widget buildItemImage(String image) {
    ImageProvider imageProvider;

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      imageProvider = NetworkImage(image);
    } else {
      imageProvider = AssetImage(
        image.isNotEmpty
            ? image
            : 'assets/images/mikroskop.jpg',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: imageProvider,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: 60,
            height: 60,
            color: const Color(0xFFF5EBE0),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF711414),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('ERROR GAMBAR: $error');

          return Container(
            width: 60,
            height: 60,
            color: const Color(0xFFF5EBE0),
            child: const Icon(
              Icons.broken_image,
              size: 35,
              color: Color(0xFF711414),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Silakan login terlebih dahulu'),
        ),
      );
    }

    // CEK ROLE ADMIN ATAU USER
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (roleSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Gagal memeriksa hak akses pengguna'),
            ),
          );
        }

        final roleData = roleSnapshot.data?.data()
            as Map<String, dynamic>?;

        final bool isAdmin = roleData?['role'] == 'admin';

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 245, 235, 221),

          // APP BAR
          appBar: AppBar(
            title: const Text('Inventaris Alat Lab'),
            titleTextStyle: const TextStyle(
              color: Color(0xFF5F0F0F),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor:
                const Color.fromARGB(255, 245, 235, 221),
            foregroundColor: const Color(0xFF5F0F0F),
          ),

          // MENGAMBIL DATA DARI FIRESTORE
          body: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5F0F0F),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Terjadi kesalahan saat mengambil data.',
                  ),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('Belum ada data inventaris'),
                );
              }

              final items = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final document = items[index];

                  final data = document.data()
                      as Map<String, dynamic>;

                  final itemName =
                      (data['item_name'] ?? '').toString();

                  final category =
                      (data['category'] ?? '').toString();

                  final code =
                      (data['code'] ?? '').toString();

                  final status =
                      (data['status'] ?? 'Available').toString();

                  final image =
                      (data['image'] ?? '').toString().trim();

                  final spesification =
                      (data['spesification'] ?? '').toString();

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // FOTO INVENTARIS
                              buildItemImage(image),

                              const SizedBox(width: 12),

                              // INFORMASI ALAT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5F0F0F),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Kategori: $category'),
                                    Text('Kode: $code'),
                                    Text('Status: $status'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // TOMBOL AKSI
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              // DETAIL
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailItemPage(
                                        itemId: document.id,
                                        itemName: itemName,
                                        category: category,
                                        code: code,
                                        status: status,
                                        image: image,
                                        spesification: spesification,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.info_outline),
                                label: const Text('Detail'),
                              ),

                              // EDIT - ADMIN SAJA
                              if (isAdmin)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditItemPage(
                                          itemId: document.id,
                                          itemName: itemName,
                                          category: category,
                                          code: code,
                                          status: status,
                                          image: image,
                                          spesification: spesification,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                ),

                              // PINJAM
                              if (status == 'Available')
                                ElevatedButton.icon(
                                  onPressed: () {
                                    borrowItem(
                                      document.id,
                                      itemName,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.shopping_bag,
                                  ),
                                  label: const Text('Pinjam'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF5F0F0F),
                                    foregroundColor: Colors.white,
                                  ),
                                ),

                              // KEMBALIKAN
                              if (status == 'Borrowed')
                                ElevatedButton.icon(
                                  onPressed: () {
                                    returnItem(document.id);
                                  },
                                  icon: const Icon(
                                    Icons.assignment_return,
                                  ),
                                  label: const Text('Kembalikan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                  ),
                                ),

                              // HAPUS - ADMIN SAJA
                              if (isAdmin)
                                IconButton(
                                  onPressed: () {
                                    deleteItem(document.id);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Hapus',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // TOMBOL TAMBAH - ADMIN SAJA
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  backgroundColor: const Color(0xFF5F0F0F),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddItemPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}
