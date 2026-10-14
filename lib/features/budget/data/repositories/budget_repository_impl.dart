import 'package:utsproject/features/budget/data/datasources/budget_remote_datasource.dart';
import 'package:utsproject/features/budget/data/models/budget_model.dart';
import 'package:utsproject/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource dataSource;
  BudgetRepositoryImpl({required this.dataSource});

  @override
  Future<BudgetModel> getBudget() => dataSource.getBudget();

  @override
  Future<void> setBudget(double amount) => dataSource.setBudget(amount);
}