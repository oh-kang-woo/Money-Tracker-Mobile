import 'package:cloud_firestore/cloud_firestore.dart';

class DebtModel {
  final String? id;
  final String userId;
  final String personName;
  final String title;
  final double amount;
  final String type; // 'payable' (Hutang Saya) atau 'receivable' (Piutang)
  final String wallet;
  final DateTime dueDate;
  final bool isPaid;

  DebtModel({
    this.id,
    required this.userId,
    required this.personName,
    required this.title,
    required this.amount,
    required this.type,
    this.wallet = 'Tunai',
    required this.dueDate,
    this.isPaid = false,
  });

  factory DebtModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DebtModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      personName: data['personName'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'payable',
      wallet: data['wallet'] ?? 'Tunai',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'personName': personName,
      'title': title,
      'amount': amount,
      'type': type,
      'wallet': wallet,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
    };
  }
}