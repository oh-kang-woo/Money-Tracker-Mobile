import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';
import 'package:utsproject/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            AuthTextField(controller: nameController, label: 'Full Name', icon: Icons.person),
            const SizedBox(height: 16),
            AuthTextField(controller: emailController, label: 'Email', icon: Icons.email),
            const SizedBox(height: 16),
            AuthTextField(controller: passwordController, label: 'Password', icon: Icons.lock, isPassword: true),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {},
              child: const Text('Register', style: TextStyle(color: AppColors.textOnYellow, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}