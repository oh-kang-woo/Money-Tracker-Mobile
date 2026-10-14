import 'package:flutter/material.dart';
import 'package:utsproject/features/transaction/data/models/transaction_model.dart';
import 'package:utsproject/features/transaction/domain/repositories/transaction_repository.dart';

class TransactionController extends ChangeNotifier {
  final TransactionRepository repository;
  TransactionController({required this.repository});

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await repository.getTransactions();
    _isLoading = false;
    notifyListeners();
  }
}