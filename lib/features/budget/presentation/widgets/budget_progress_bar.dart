import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  final Color? color;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: percentage.clamp(0.0, 1.0),
        backgroundColor: AppColors.cardSecondary,
        color: color ?? AppColors.primaryBlue,
        minHeight: 12,
      ),
    );
  }
}