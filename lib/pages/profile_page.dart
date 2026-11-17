
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

// WARNA
const Color creamColor = Color(0xFFF5EBDD);
const Color maroonColor = Color(0xFF8D2222);
const Color darkMaroonColor = Color(0xFF5F0F0F);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  String? _photoBase64;
  bool _loadingPhoto = true;

  String get photoKey {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return 'profile_photo_$uid';
  }

  @override
  void initState() {
    super.initState();
    loadProfilePhoto();
  }

  // MEMUAT FOTO PROFIL
  Future<void> loadProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPhoto = prefs.getString(photoKey);

    if (!mounted) return;

    setState(() {
      _photoBase64 = savedPhoto;
      _loadingPhoto = false;
    });
  }

  // GANTI FOTO DARI GALERI LAPTOP
  Future<void> changeProfilePhoto() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 70,
      );

      if (pickedImage == null) return;

      final bytes = await pickedImage.readAsBytes();

      final encodedPhoto = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(photoKey, encodedPhoto);

      if (!mounted) return;

      setState(() {
        _photoBase64 = encodedPhoto;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diganti!'),
          backgroundColor: maroonColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengganti foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // LOGOUT
  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: creamColor,
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: maroonColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (route) => false,
      );
    }
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

    return Scaffold(
      backgroundColor: creamColor,

      appBar: AppBar(
        backgroundColor: maroonColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: maroonColor,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Data profil tidak ditemukan'),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final name = data['name'] ?? 'Nama Pengguna';
          final email = data['email'] ?? user.email ?? '-';
          final kelas = data['kelas'] ?? '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                // FOTO PROFIL
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: maroonColor,
                      width: 3,
                    ),
                  ),

                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,

                    backgroundImage: _photoBase64 != null
                        ? MemoryImage(
                            base64Decode(_photoBase64!),
                          )
                        : null,

                    child: _loadingPhoto
                        ? const CircularProgressIndicator(
                            color: maroonColor,
                          )
                        : _photoBase64 == null
                            ? const Icon(
                                Icons.person,
                                size: 65,
                                color: maroonColor,
                              )
                            : null,
                  ),
                ),

                const SizedBox(height: 12),

                // TOMBOL GANTI FOTO
                OutlinedButton.icon(
                  onPressed: _loadingPhoto
                      ? null
                      : changeProfilePhoto,

                  icon: const Icon(
                    Icons.camera_alt,
                    size: 18,
                  ),

                  label: const Text('Ganti Foto Profil'),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: maroonColor,
                    side: const BorderSide(
                      color: maroonColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // NAMA
                Text(
                  name.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkMaroonColor,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email.toString(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                // INFORMASI PROFIL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: maroonColor,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Nama Lengkap',
                        style: TextStyle(color: Colors.grey),
                      ),

                      Text(
                        name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Email',
                        style: TextStyle(color: Colors.grey),
                      ),

                      Text(
                        email.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Kelas',
                        style: TextStyle(color: Colors.grey),
                      ),

                      Text(
                        kelas.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // RIWAYAT PEMINJAMAN
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Riwayat Peminjaman',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: darkMaroonColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('borrowings')
                      .orderBy(
                        'borrow_date',
                        descending: true,
                      )
                      .limit(5)
                      .snapshots(),

                  builder: (context, borrowSnapshot) {
                    if (borrowSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: maroonColor,
                      );
                    }

                    if (borrowSnapshot.hasError) {
                      return const Text(
                        'Gagal memuat riwayat peminjaman',
                      );
                    }

                    if (!borrowSnapshot.hasData ||
                        borrowSnapshot.data!.docs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: const Text(
                          'Belum ada riwayat peminjaman',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: borrowSnapshot.data!.docs.map((doc) {
                        final borrowing =
                            doc.data() as Map<String, dynamic>;

                        final itemName =
                            borrowing['item_name'] ?? 'Nama Alat';

                        final borrowDate =
                            borrowing['borrow_date'] as Timestamp?;

                        final returnDate =
                            borrowing['return_date'];

                        final dateText = borrowDate != null
                            ? '${borrowDate.toDate().day}/'
                                '${borrowDate.toDate().month}/'
                                '${borrowDate.toDate().year}'
                            : 'Tanggal belum tersedia';

                        final status = returnDate == null
                            ? 'Sedang Dipinjam'
                            : 'Sudah Dikembalikan';

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: creamColor,
                                child: Icon(
                                  Icons.science,
                                  color: maroonColor,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      'Tanggal: $dateText',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: returnDate == null
                                            ? maroonColor
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // TOMBOL LOGOUT
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed: () => logout(context),

                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),

                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
