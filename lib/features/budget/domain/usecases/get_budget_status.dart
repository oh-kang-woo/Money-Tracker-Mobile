import 'package:utsproject/features/budget/data/models/budget_model.dart';
import 'package:utsproject/features/budget/domain/repositories/budget_repository.dart';

class GetBudgetStatus {
  final BudgetRepository repository;
  GetBudgetStatus(this.repository);

  Future<BudgetModel> call() => repository.getBudget();
}