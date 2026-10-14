import 'package:utsproject/features/transaction/domain/repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;
  DeleteTransaction(this.repository);

  Future<void> call(String id) => repository.deleteTransaction(id);
}