import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';

class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  const BudgetProgressBar({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: percentage,
      backgroundColor: AppColors.cardSecondary,
      color: AppColors.primaryYellow,
      minHeight: 10,
    );
  }
}