import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/constants/firebase_collections.dart';
import '../models/transaction_model.dart';

class TransactionController {
  final CollectionReference _trxRef = FirebaseFirestore.instance
      .collection(FirebaseCollections.transactions);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // CREATE
  Future<void> addTransaction(TransactionModel trx) async {
    final uid = _uid;
    if (uid == null) throw Exception('Sesi pengguna tidak ditemukan.');

    final data = trx.toMap();
    data['userId'] = uid;
    await _trxRef.add(data);
  }

  // READ (Real-time Stream terisolasi per userId)
  Stream<List<TransactionModel>> getTransactionsStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _trxRef
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
      // Urutkan di memori agar tidak bergantung pada composite index saat demo
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  // UPDATE
  Future<void> updateTransaction(TransactionModel trx) async {
    final uid = _uid;
    if (trx.id == null || uid == null) return;

    final data = trx.toMap();
    data['userId'] = uid;
    await _trxRef.doc(trx.id).update(data);
  }

  // DELETE
  Future<void> deleteTransaction(String id) async {
    if (_uid == null) return;
    await _trxRef.doc(id).delete();
  }
}