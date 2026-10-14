import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(child: Text('Analytics View', style: TextStyle(color: AppColors.textPrimary))),
    );
  }
}