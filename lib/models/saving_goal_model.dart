import 'package:cloud_firestore/cloud_firestore.dart';

class SavingGoalModel {
  final String? id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;

  SavingGoalModel({
    this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.deadline,
  });

  factory SavingGoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingGoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      deadline: (data['deadline'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': Timestamp.fromDate(deadline),
    };
  }
}