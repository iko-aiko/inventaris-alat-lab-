
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final FirestoreService firestoreService = FirestoreService();

  final itemNameController = TextEditingController();
  final categoryController = TextEditingController();
  final codeController = TextEditingController();
  final imageController = TextEditingController();
  final spesificationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? selectedCategory;
  String status = 'Available';
  bool isLoading = false;

  // MENYIMPAN DATA
  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await firestoreService.addItem(
        itemName: itemNameController.text.trim(),
        category: selectedCategory!,
        code: codeController.text.trim(),
        status: status,
        image: imageController.text.trim(),
        spesification: spesificationController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data alat berhasil ditambahkan!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan data: $e'),
        ),
      );
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

      // APP BAR
      appBar: AppBar(
        title: const Text('Tambah Alat'),
        backgroundColor:
            const Color.fromARGB(255, 245, 235, 221),
        foregroundColor: const Color(0xFF5F0F0F),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              // NAMA ALAT
              TextFormField(
                controller: itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Alat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.science),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama alat wajib diisi!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // KATEGORI DROPDOWN
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                hint: const Text('Pilih Kategori'),

                items: const [
                  DropdownMenuItem(
                    value: 'Optik',
                    child: Text('Optik'),
                  ),
                  DropdownMenuItem(
                    value: 'Elektronik',
                    child: Text('Elektronik'),
                  ),
                  DropdownMenuItem(
                    value: 'Komputer',
                    child: Text('Komputer'),
                  ),
                  DropdownMenuItem(
                    value: 'Alat Ukur',
                    child: Text('Alat Ukur'),
                  ),
                ],

                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori wajib dipilih!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // KODE ALAT
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Alat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Kode alat wajib diisi!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // STATUS DROPDOWN
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Available',
                    child: Text('Available'),
                  ),
                  DropdownMenuItem(
                    value: 'Borrowed',
                    child: Text('Borrowed'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Status wajib dipilih!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // GAMBAR
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Gambar / URL Gambar',
                  hintText: 'assets/images/mikroskop.jpg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Gambar wajib diisi!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // SPESIFIKASI
              TextFormField(
                controller: spesificationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Spesifikasi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Spesifikasi wajib diisi!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F0F0F),
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Simpan Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
