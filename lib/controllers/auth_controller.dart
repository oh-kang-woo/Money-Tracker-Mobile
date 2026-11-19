import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/constants/firebase_collections.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection(FirebaseCollections.users);

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // LOGIN
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // REGISTER + Simpan profil awal ke Firestore
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      await _usersRef.doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'monthlyBudget': 2000000.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // STREAM DATA PROFIL & BUDGET USER
  Stream<DocumentSnapshot> getUserProfileStream() {
    final uid = currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _usersRef.doc(uid).snapshots();
  }

  // UPDATE BATAS ANGGARAN BULANAN
  Future<void> updateMonthlyBudget(double newBudget) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _usersRef.doc(uid).set(
      {'monthlyBudget': newBudget},
      SetOptions(merge: true),
    );
  }

  // RESET PASSWORD VIA EMAIL
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // UPDATE NAMA PENGGUNA
  Future<void> updateDisplayName(String newName) async {
    final user = currentUser;
    if (user == null) return;
    await user.updateDisplayName(newName.trim());
    await _usersRef.doc(user.uid).set(
      {'name': newName.trim()},
      SetOptions(merge: true),
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}