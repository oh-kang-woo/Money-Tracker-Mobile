import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/constants/firebase_collections.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // LOGIN
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // REGISTER
  Future<UserCredential> register(
    String name,
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
      await _firestore.collection(FirebaseCollections.users).doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'monthlyBudget': 2000000,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return credential;
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // STREAM PROFIL & ANGGARAN USER
  Stream<DocumentSnapshot> getUserProfileStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .snapshots();
  }

  // UPDATE ANGGARAN BULANAN
  Future<void> updateMonthlyBudget(double budget) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection(FirebaseCollections.users).doc(uid).set({
      'monthlyBudget': budget,
    }, SetOptions(merge: true));
  }

  // UPDATE NAMA PROFIL
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name);
    await user.reload();
    await _firestore.collection(FirebaseCollections.users).doc(user.uid).set({
      'name': name,
    }, SetOptions(merge: true));
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}