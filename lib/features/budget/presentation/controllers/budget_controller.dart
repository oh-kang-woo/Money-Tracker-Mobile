import 'package:flutter/material.dart';
import 'package:utsproject/features/budget/data/models/budget_model.dart';
import 'package:utsproject/features/budget/domain/repositories/budget_repository.dart';

class BudgetController extends ChangeNotifier {
  final BudgetRepository repository;
  BudgetController({required this.repository});

  BudgetModel? _budget;
  BudgetModel? get budget => _budget;

  Future<void> fetchBudget() async {
    _budget = await repository.getBudget();
    notifyListeners();
  }
}