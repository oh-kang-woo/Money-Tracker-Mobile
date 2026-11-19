import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/constants/firebase_collections.dart';
import '../models/debt_model.dart';
import '../models/transaction_model.dart';
import 'transaction_controller.dart';

class DebtController {
  final CollectionReference _debtsRef =
      FirebaseFirestore.instance.collection(FirebaseCollections.debts);
  final TransactionController _trxController = TransactionController();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // CREATE
  Future<void> addDebt(
    DebtModel debt, {
    bool affectWalletNow = false,
  }) async {
    await _debtsRef.add(debt.toMap());

    // Jika diaktifkan, langsung sesuaikan saldo dompet saat pencatatan awal
    if (affectWalletNow && _uid != null) {
      final isPayable = debt.type == 'payable';
      await _trxController.addTransaction(
        TransactionModel(
          userId: _uid!,
          title: isPayable
              ? 'Pinjaman dari ${debt.personName} (${debt.title})'
              : 'Pinjamkan ke ${debt.personName} (${debt.title})',
          amount: debt.amount,
          type: isPayable ? 'income' : 'expense',
          category: 'Lainnya',
          wallet: debt.wallet,
          date: DateTime.now(),
        ),
      );
    }
  }

  // READ (Real-time per User, belum lunas tampil di atas)
  Stream<List<DebtModel>> getDebtsStream() {
    if (_uid == null) return Stream.value([]);
    return _debtsRef
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map((doc) => DebtModel.fromFirestore(doc)).toList();
      list.sort((a, b) {
        if (a.isPaid != b.isPaid) {
          return a.isPaid ? 1 : -1;
        }
        return a.dueDate.compareTo(b.dueDate);
      });
      return list;
    });
  }

  // LUNASI HUTANG / PIUTANG -> Tandai lunas & catat ke transaksi dompet
  Future<void> settleDebt(DebtModel debt) async {
    if (debt.id == null || _uid == null) return;

    await _debtsRef.doc(debt.id).update({'isPaid': true});

    final isPayable = debt.type == 'payable';
    await _trxController.addTransaction(
      TransactionModel(
        userId: _uid!,
        title: isPayable
            ? 'Bayar hutang ke ${debt.personName}'
            : 'Pelunasan piutang dari ${debt.personName}',
        amount: debt.amount,
        type: isPayable ? 'expense' : 'income',
        category: 'Lainnya',
        wallet: debt.wallet,
        date: DateTime.now(),
      ),
    );
  }

  // DELETE
  Future<void> deleteDebt(String id) async {
    await _debtsRef.doc(id).delete();
  }
}