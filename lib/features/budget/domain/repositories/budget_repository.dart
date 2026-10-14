import 'package:utsproject/features/budget/data/models/budget_model.dart';

abstract class BudgetRepository {
  Future<BudgetModel> getBudget();
  Future<void> setBudget(double amount);
}