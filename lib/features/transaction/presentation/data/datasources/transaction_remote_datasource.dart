import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> addTransaction(TransactionModel transaction);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final List<TransactionModel> _dummyData = [
    TransactionModel(
      id: '1',
      title: 'Investments',
      amount: 500.00,
      date: DateTime(2025, 8, 5, 10, 0),
      category: 'Investment',
      isExpense: false,
    ),
    TransactionModel(
      id: '2',
      title: 'Gift',
      amount: 100.00,
      date: DateTime(2025, 8, 10, 0, 0),
      category: 'Gift',
      isExpense: true,
    ),
    TransactionModel(
      id: '3',
      title: 'Pet',
      amount: 200.00,
      date: DateTime(2025, 8, 12, 8, 0),
      category: 'Pet',
      isExpense: true,
    ),
    TransactionModel(
      id: '4',
      title: 'Shopping',
      amount: 236.00,
      date: DateTime(2025, 8, 15, 10, 0),
      category: 'Shopping',
      isExpense: true,
    ),
  ];

  @override
  Future<List<TransactionModel>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _dummyData;
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _dummyData.insert(0, transaction);
  }
}