import 'package:utsproject/features/transaction/data/models/transaction_model.dart';
import 'package:utsproject/features/transaction/domain/repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;
  GetTransactions(this.repository);

  Future<List<TransactionModel>> call() => repository.getTransactions();
}