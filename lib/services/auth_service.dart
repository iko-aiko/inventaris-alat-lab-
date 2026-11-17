
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER
  Future<void> register({
    required String name,
    required String kelas,
    required String email,
    required String password,
  }) async {
    UserCredential result =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(result.user!.uid).set({
      'user_id': result.user!.uid,
      'name': name,
      'email': email,
      'kelas': kelas,
      'created_at': FieldValue.serverTimestamp(),
      'foto': '',
    });
  }

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
