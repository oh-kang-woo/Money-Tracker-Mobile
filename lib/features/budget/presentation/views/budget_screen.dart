import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';
import 'package:utsproject/features/analytics/presentation/widgets/category_pie_chart.dart';
import 'package:utsproject/features/analytics/presentation/widgets/expense_chart.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              ExpenseChart(),
              SizedBox(height: 20),
              CategoryPieChart(),
            ],
          ),
        ),
      ),
    );
  }
}