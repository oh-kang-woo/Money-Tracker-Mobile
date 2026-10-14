import 'package:utsproject/features/budget/domain/repositories/budget_repository.dart';

class SetBudget {
  final BudgetRepository repository;
  SetBudget(this.repository);

  Future<void> call(double amount) => repository.setBudget(amount);
}