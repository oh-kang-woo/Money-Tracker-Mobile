import 'package:utsproject/features/transaction/data/models/transaction_model.dart';
import 'package:utsproject/features/transaction/domain/repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;
  UpdateTransaction(this.repository);

  Future<void> call(TransactionModel transaction) => repository.updateTransaction(transaction);
}