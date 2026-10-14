import 'package:utsproject/features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'package:utsproject/features/transaction/data/models/transaction_model.dart';
import 'package:utsproject/features/transaction/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource dataSource;
  TransactionRepositoryImpl({required this.dataSource});

  @override
  Future<List<TransactionModel>> getTransactions() => dataSource.getTransactions();

  @override
  Future<void> addTransaction(TransactionModel transaction) => dataSource.addTransaction(transaction);

  @override
  Future<void> updateTransaction(TransactionModel transaction) => dataSource.updateTransaction(transaction);

  @override
  Future<void> deleteTransaction(String id) => dataSource.deleteTransaction(id);
}