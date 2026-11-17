
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class DetailItemPage extends StatefulWidget {
  final String itemId;
  final String itemName;
  final String category;
  final String code;
  final String status;
  final String image;
  final String spesification;

  const DetailItemPage({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.code,
    required this.status,
    required this.image,
    required this.spesification,
  });

  @override
  State<DetailItemPage> createState() => _DetailItemPageState();
}

class _DetailItemPageState extends State<DetailItemPage> {
  final FirestoreService firestoreService = FirestoreService();

  bool isLoading = false;

  final Color maroon = const Color(0xFF5F0F0F);
  final Color cream = const Color(0xFFF5EBDD);

  Future<void> borrowItem() async {
    setState(() => isLoading = true);

    try {
      await firestoreService.borrowItem(
        itemId: widget.itemId,
        itemName: widget.itemName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman berhasil diajukan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal meminjam alat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildItemImage() {
    final imagePath = widget.image.trim();

    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: 380,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, size: 70),
          );
        },
      );
    }

    return Image.asset(
      imagePath.isNotEmpty
          ? imagePath
          : 'assets/images/mikroskop.jpg',
      width: double.infinity,
      height: 380,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, size: 70),
        );
      },
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: maroon,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value.isNotEmpty ? value : '-')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.status == 'Available';

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text(
          'Detail Inventaris',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: cream,
        foregroundColor: maroon,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR FULL LEBAR LAYAR
            SizedBox(
              width: double.infinity,
              height: 380,
              child: buildItemImage(),
            ),

            // INFORMASI ALAT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.itemName,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: maroon,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: TextStyle(
                        color: isAvailable
                            ? Colors.green.shade800
                            : Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Alat',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: maroon,
                          ),
                        ),
                        const SizedBox(height: 12),
                        detailRow('Nama Alat', widget.itemName),
                        const Divider(),
                        detailRow('Kategori', widget.category),
                        const Divider(),
                        detailRow('Kode Alat', widget.code),
                        const Divider(),
                        detailRow('Status', widget.status),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spesifikasi Alat',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: maroon,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.spesification.isNotEmpty
                              ? widget.spesification
                              : 'Belum ada spesifikasi alat.',
                          style: const TextStyle(height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed:
                          isAvailable && !isLoading
                              ? borrowItem
                              : null,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.shopping_bag_outlined),
                      label: Text(
                        isAvailable
                            ? 'Ajukan Peminjaman'
                            : 'Alat Sedang Dipinjam',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
