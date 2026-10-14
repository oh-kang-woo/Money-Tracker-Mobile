import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(24)),
      child: const Text('Monthly Statistics Chart', style: TextStyle(color: AppColors.textPrimary)),
    );
  }
}