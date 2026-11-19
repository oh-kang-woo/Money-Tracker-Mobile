import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String? id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final String wallet;
  final int dueDay; // Tanggal jatuh tempo tiap bulan (1 - 31)
  final String lastPaidMonth; // Format 'YYYY-MM', misal '2026-11'

  BillModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    this.category = 'Tagihan',
    this.wallet = 'Bank',
    required this.dueDay,
    this.lastPaidMonth = '',
  });

  bool isPaidForMonth(DateTime date) {
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    return lastPaidMonth == key;
  }

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Tagihan',
      wallet: data['wallet'] ?? 'Bank',
      dueDay: (data['dueDay'] ?? 1).toInt(),
      lastPaidMonth: data['lastPaidMonth'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'wallet': wallet,
      'dueDay': dueDay,
      'lastPaidMonth': lastPaidMonth,
    };
  }
}