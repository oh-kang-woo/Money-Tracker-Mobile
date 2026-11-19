import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // LOGIN
  Future<UserCredential> signIn(String email, String password) async {
    // Tambahkan .trim() untuk membuang spasi tidak sengaja
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();
    
    return await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );
  }

  // REGISTER
  Future<UserCredential> signUp(String email, String password) async {
    // Tambahkan .trim() untuk membuang spasi tidak sengaja
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();
    
    return await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}