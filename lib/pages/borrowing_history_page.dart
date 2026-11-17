
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BorrowingHistoryPage extends StatelessWidget {
  const BorrowingHistoryPage({super.key});

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Belum tersedia';
    }

    final date = timestamp.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Silakan login terlebih dahulu'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('borrowings')
            .orderBy('borrow_date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil riwayat peminjaman'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final borrowings = snapshot.data!.docs;

          if (borrowings.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat peminjaman'),
            );
          }

          return ListView.builder(
            itemCount: borrowings.length,
            itemBuilder: (context, index) {
              final data = borrowings[index].data();

              final borrowDate = data['borrow_date'] as Timestamp?;
              final returnDate = data['return_date'] as Timestamp?;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(data['item_name'] ?? '-'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Dipinjam: ${formatDate(borrowDate)}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tanggal Dikembalikan: ${formatDate(returnDate)}',
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(
                    returnDate == null
                        ? Icons.access_time
                        : Icons.check_circle_outline,
                    color: returnDate == null
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
