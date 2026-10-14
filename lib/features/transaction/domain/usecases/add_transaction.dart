import 'package:utsproject/features/transaction/data/models/transaction_model.dart';
import 'package:utsproject/features/transaction/domain/repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  Future<void> call(TransactionModel transaction) => repository.addTransaction(transaction);
}