import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/constants/firebase_collections.dart';
import '../models/saving_goal_model.dart';

class SavingGoalController {
  final CollectionReference _goalsRef = FirebaseFirestore.instance
      .collection(FirebaseCollections.savingGoals);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // CREATE
  Future<void> addGoal(SavingGoalModel goal) async {
    await _goalsRef.add(goal.toMap());
  }

  // READ (Real-time per User)
  Stream<List<SavingGoalModel>> getGoalsStream() {
    if (_uid == null) return Stream.value([]);
    return _goalsRef
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SavingGoalModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => a.deadline.compareTo(b.deadline));
      return list;
    });
  }

  // TAMBAH SALDO TABUNGAN
  Future<void> addFunds(String id, double amount) async {
    await _goalsRef.doc(id).update({
      'currentAmount': FieldValue.increment(amount),
    });
  }

  // DELETE
  Future<void> deleteGoal(String id) async {
    await _goalsRef.doc(id).delete();
  }
}