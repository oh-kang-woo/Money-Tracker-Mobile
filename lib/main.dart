import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';
import 'package:utsproject/features/transaction/presentation/views/transaction_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App UTS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const TransactionListScreen(),
    );
  }
}