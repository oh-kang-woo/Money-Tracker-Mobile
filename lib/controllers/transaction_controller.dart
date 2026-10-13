import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  // Data private, hanya bisa dimodifikasi dari dalam controller
  final List<TransactionModel> _transactions = [];

  // Getter untuk mengambil data dari luar
  List<TransactionModel> get transactions => _transactions;

  // Logika menghitung total saldo
  double get totalBalance {
    return _transactions.fold(0, (sum, item) => sum + item.amount);
  }

  // Logika menambahkan transaksi baru
  void addTransaction(String title, double amount) {
    final newTransaction = TransactionModel(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
    );
    _transactions.add(newTransaction);
    
    // Memberi tahu View bahwa ada perubahan data agar UI diperbarui
    notifyListeners(); 
  }
}