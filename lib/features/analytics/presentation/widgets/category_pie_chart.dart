import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(24)),
      child: const Text('Category Pie Chart', style: TextStyle(color: AppColors.textPrimary)),
    );
  }
}