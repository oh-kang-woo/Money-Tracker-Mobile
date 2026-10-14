import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';

class AddEditTransactionScreen extends StatelessWidget {
  const AddEditTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Transaction'), backgroundColor: AppColors.cardBackground),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Form Input Transaksi', style: TextStyle(color: AppColors.textPrimary)),
        ),
      ),
    );
  }
}