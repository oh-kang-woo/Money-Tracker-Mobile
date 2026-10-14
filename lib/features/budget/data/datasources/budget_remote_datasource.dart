import 'package:utsproject/features/budget/data/models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<BudgetModel> getBudget();
  Future<void> setBudget(double amount);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  BudgetModel _budget = BudgetModel(limitAmount: 6000.0, spentAmount: 5378.0);

  @override
  Future<BudgetModel> getBudget() async => _budget;

  @override
  Future<void> setBudget(double amount) async {
    _budget = BudgetModel(limitAmount: amount, spentAmount: _budget.spentAmount);
  }
}