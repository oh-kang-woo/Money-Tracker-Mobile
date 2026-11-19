import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/constants/firebase_collections.dart';
import '../models/bill_model.dart';
import '../models/transaction_model.dart';
import 'transaction_controller.dart';

class BillController {
  final CollectionReference _billsRef =
      FirebaseFirestore.instance.collection(FirebaseCollections.bills);
  final TransactionController _trxController = TransactionController();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // CREATE
  Future<void> addBill(BillModel bill) async {
    await _billsRef.add(bill.toMap());
  }

  // READ (Real-time per User)
  Stream<List<BillModel>> getBillsStream() {
    if (_uid == null) return Stream.value([]);
    return _billsRef
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList();
      list.sort((a, b) => a.dueDay.compareTo(b.dueDay));
      return list;
    });
  }

  // BAYAR TAGIHAN -> Tandai lunas bulan ini & catat ke transaksi
  Future<void> payBill(BillModel bill) async {
    if (bill.id == null || _uid == null) return;
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    await _billsRef.doc(bill.id).update({'lastPaidMonth': monthKey});

    await _trxController.addTransaction(
      TransactionModel(
        userId: _uid!,
        title: 'Bayar ${bill.title}',
        amount: bill.amount,
        type: 'expense',
        category: bill.category,
        wallet: bill.wallet,
        date: now,
      ),
    );
  }

  // DELETE
  Future<void> deleteBill(String id) async {
    await _billsRef.doc(id).delete();
  }
}