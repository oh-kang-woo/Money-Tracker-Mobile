import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('Profile Screen', style: TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }
}