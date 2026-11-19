import 'package:cloud_firestore/cloud_firestore.dart';
import '../app/constants/firebase_collections.dart';
import '../models/transaction_model.dart';

class TransactionController {
  final CollectionReference _trxRef = FirebaseFirestore.instance
      .collection(FirebaseCollections.transactions);

  // CREATE
  Future<void> addTransaction(TransactionModel trx) async {
    await _trxRef.add(trx.toMap());
  }

  // READ (Real-time Stream)
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _trxRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  // UPDATE
  Future<void> updateTransaction(TransactionModel trx) async {
    if (trx.id == null) return;
    await _trxRef.doc(trx.id).update(trx.toMap());
  }

  // DELETE
  Future<void> deleteTransaction(String id) async {
    await _trxRef.doc(id).delete();
  }
}