import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionModel {
  final String? id;
  final String userId;
  final String title;
  final double amount;
  final String type; // 'income', 'expense', atau 'transfer'
  final String category;
  final String wallet; // Dompet utama / dompet asal
  final String? toWallet; // Dompet tujuan (khusus transfer)
  final DateTime date;

  TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.wallet = 'Tunai',
    this.toWallet,
    required this.date,
  });

  static const List<String> wallets = [
    'Tunai',
    'Bank',
    'E-Wallet',
  ];

  static const List<String> expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Lainnya',
  ];

  static const List<String> incomeCategories = [
    'Gaji',
    'Bonus',
    'Usaha',
    'Lainnya',
  ];

  static IconData getWalletIcon(String wallet) {
    switch (wallet) {
      case 'Bank':
        return Icons.account_balance;
      case 'E-Wallet':
        return Icons.phone_android;
      default:
        return Icons.payments_outlined;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Tagihan':
        return Icons.receipt_long;
      case 'Hiburan':
        return Icons.movie;
      case 'Gaji':
        return Icons.payments;
      case 'Bonus':
        return Icons.card_giftcard;
      case 'Usaha':
        return Icons.storefront;
      case 'Transfer':
        return Icons.swap_horiz;
      default:
        return Icons.account_balance_wallet;
    }
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'expense',
      category: data['category'] ?? 'Lainnya',
      wallet: data['wallet'] ?? 'Tunai',
      toWallet: data['toWallet'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'wallet': wallet,
      'toWallet': toWallet,
      'date': Timestamp.fromDate(date),
    };
  }
}