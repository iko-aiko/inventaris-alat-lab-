
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // READ: Mengambil data inventaris secara real-time
  Stream<QuerySnapshot> getItems() {
    return _firestore.collection('items').snapshots();
  }

  // CREATE: Menambahkan alat baru
  Future<void> addItem({
    required String itemName,
    required String category,
    required String code,
    required String status,
    required String image,
    required String spesification,
  }) async {
    final doc = _firestore.collection('items').doc();

    await doc.set({
      'item_id': doc.id,
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': status,
      'image': image,
      'spesification': spesification,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE: Mengubah data alat
  Future<void> updateItem({
    required String itemId,
    required String itemName,
    required String category,
    required String code,
    required String status,
    required String image,
    required String spesification,
  }) async {
    await _firestore.collection('items').doc(itemId).update({
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': status,
      'image': image,
      'spesification': spesification,
    });
  }

  // DELETE: Menghapus data alat
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('items').doc(itemId).delete();
  }

  // BORROW: Meminjam alat
  Future<void> borrowItem({
    required String itemId,
    required String itemName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu');
    }

    final borrowingRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('borrowings')
        .doc();

    await _firestore.runTransaction((transaction) async {
      final itemRef = _firestore.collection('items').doc(itemId);
      final itemSnapshot = await transaction.get(itemRef);

      if (!itemSnapshot.exists) {
        throw Exception('Alat tidak ditemukan');
      }

      final status = itemSnapshot.data()?['status'];

      if (status != 'Available') {
        throw Exception('Alat sedang dipinjam');
      }

      transaction.update(itemRef, {
        'status': 'Borrowed',
      });

      transaction.set(borrowingRef, {
        'borrow_id': borrowingRef.id,
        'item_id': itemId,
        'item_name': itemName,
        'borrow_date': FieldValue.serverTimestamp(),
        'return_date': null,
      });
    });
  }

  // RETURN: Mengembalikan alat
  Future<void> returnItem({
    required String itemId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu');
    }

    final borrowingsRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('borrowings');

    final borrowingQuery = await borrowingsRef
        .where('item_id', isEqualTo: itemId)
        .get();

    final activeBorrowings = borrowingQuery.docs.where((doc) {
      return doc.data()['return_date'] == null;
    }).toList();

    if (activeBorrowings.isEmpty) {
      throw Exception('Riwayat peminjaman tidak ditemukan');
    }

    final borrowingRef = activeBorrowings.first.reference;
    final itemRef = _firestore.collection('items').doc(itemId);

    await _firestore.runTransaction((transaction) async {
      final itemSnapshot = await transaction.get(itemRef);

      if (!itemSnapshot.exists) {
        throw Exception('Alat tidak ditemukan');
      }

      transaction.update(itemRef, {
        'status': 'Available',
      });

      transaction.update(borrowingRef, {
        'return_date': FieldValue.serverTimestamp(),
      });
    });
  }
}
