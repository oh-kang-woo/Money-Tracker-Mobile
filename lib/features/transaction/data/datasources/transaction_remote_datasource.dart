import 'package:utsproject/features/transaction/data/models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final List<TransactionModel> _items = [
    TransactionModel(id: '1', title: 'Investments', amount: 500.0, date: DateTime(2025, 8, 5), category: 'Invest', isExpense: false),
    TransactionModel(id: '2', title: 'Gift', amount: 100.0, date: DateTime(2025, 8, 10), category: 'Gift', isExpense: true),
    TransactionModel(id: '3', title: 'Pet', amount: 200.0, date: DateTime(2025, 8, 12), category: 'Pet', isExpense: true),
    TransactionModel(id: '4', title: 'Shopping', amount: 236.0, date: DateTime(2025, 8, 15), category: 'Shopping', isExpense: true),
  ];

  @override
  Future<List<TransactionModel>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _items;
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    _items.insert(0, transaction);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _items.indexWhere((t) => t.id == transaction.id);
    if (index != -1) _items[index] = transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _items.removeWhere((t) => t.id == id);
  }
}