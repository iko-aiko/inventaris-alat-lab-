import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditItemPage extends StatefulWidget {
  final String itemId;
  final String itemName;
  final String category;
  final String code;
  final String status;
  final String image;
  final String spesification;

  const EditItemPage({
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
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final FirestoreService firestoreService = FirestoreService();

  late TextEditingController itemNameController;
  late TextEditingController categoryController;
  late TextEditingController codeController;
  late TextEditingController imageController;
  late TextEditingController spesificationController;

  late String status;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    itemNameController = TextEditingController(text: widget.itemName);
    categoryController = TextEditingController(text: widget.category);
    codeController = TextEditingController(text: widget.code);
    imageController = TextEditingController(text: widget.image);
    spesificationController = TextEditingController(text: widget.spesification);

    status = widget.status;
  }

  Future<void> updateItem() async {
    setState(() {
      isLoading = true;
    });

    try {
      await firestoreService.updateItem(
        itemId: widget.itemId,
        itemName: itemNameController.text.trim(),
        category: categoryController.text.trim(),
        code: codeController.text.trim(),
        status: status,
        image: imageController.text.trim(),
        spesification: spesificationController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diperbarui!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui data: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    itemNameController.dispose();
    categoryController.dispose();
    codeController.dispose();
    imageController.dispose();
    spesificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 235, 221),

      appBar: AppBar(
        title: const Text('Edit Alat'),
        titleTextStyle: const TextStyle(
          color: Color(0xFF5F0F0F),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color.fromARGB(255, 245, 235, 221),
        foregroundColor: const Color(0xFF5F0F0F),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Alat',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Alat',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Available', child: Text('Available')),
                DropdownMenuItem(value: 'Borrowed', child: Text('Borrowed')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    status = value;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: 'URL Gambar',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: spesificationController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Spesifikasi',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F0F0F),
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
