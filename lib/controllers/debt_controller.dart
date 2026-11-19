import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/constants/firebase_collections.dart';
import '../models/debt_model.dart';
import '../models/transaction_model.dart';

class DebtController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _debtsRef =
      _firestore.collection(FirebaseCollections.debts);
  late final CollectionReference _trxRef =
      _firestore.collection(FirebaseCollections.transactions);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // CREATE (Atomik antara catatan utang dan mutasi saldo awal jika aktif)
  Future<void> addDebt(
    DebtModel debt, {
    bool affectWalletNow = false,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Sesi pengguna tidak ditemukan.');

    final batch = _firestore.batch();
    final newDebtDoc = _debtsRef.doc();
    final debtData = debt.toMap();
    debtData['userId'] = uid;
    batch.set(newDebtDoc, debtData);

    if (affectWalletNow) {
      final isPayable = debt.type == 'payable';
      final newTrxDoc = _trxRef.doc();
      final trx = TransactionModel(
        userId: uid,
        title: isPayable
            ? 'Pinjaman dari ${debt.personName} (${debt.title})'
            : 'Pinjamkan ke ${debt.personName} (${debt.title})',
        amount: debt.amount,
        type: isPayable ? 'income' : 'expense',
        category: 'Lainnya',
        wallet: debt.wallet,
        date: DateTime.now(),
      );
      batch.set(newTrxDoc, trx.toMap());
    }

    await batch.commit();
  }

  // READ (Real-time per User, belum lunas tampil di atas)
  Stream<List<DebtModel>> getDebtsStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _debtsRef
        .where('userId', isEqualTo: uid)
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

  // LUNASI HUTANG / PIUTANG (Atomik & anti-duplikasi pelunasan)
  Future<void> settleDebt(DebtModel debt) async {
    final uid = _uid;
    if (debt.id == null || uid == null) return;

    final debtDocRef = _debtsRef.doc(debt.id);
    final newTrxDocRef = _trxRef.doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(debtDocRef);
      if (!snapshot.exists) {
        throw Exception('Data utang tidak ditemukan.');
      }

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data?['isPaid'] == true) {
        throw Exception('Utang/piutang ini sudah berstatus lunas.');
      }

      transaction.update(debtDocRef, {'isPaid': true});

      final isPayable = debt.type == 'payable';
      final trx = TransactionModel(
        userId: uid,
        title: isPayable
            ? 'Bayar hutang ke ${debt.personName}'
            : 'Pelunasan piutang dari ${debt.personName}',
        amount: debt.amount,
        type: isPayable ? 'expense' : 'income',
        category: 'Lainnya',
        wallet: debt.wallet,
        date: DateTime.now(),
      );
      transaction.set(newTrxDocRef, trx.toMap());
    });
  }

  // DELETE
  Future<void> deleteDebt(String id) async {
    if (_uid == null) return;
    await _debtsRef.doc(id).delete();
  }
}