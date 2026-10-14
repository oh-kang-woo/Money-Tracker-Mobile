import 'package:flutter/material.dart';
import 'package:utsproject/features/auth/data/models/user_model.dart';
import 'package:utsproject/features/auth/domain/usecases/login_usecase.dart';
import 'package:utsproject/features/auth/domain/usecases/logout_usecase.dart';
import 'package:utsproject/features/auth/domain/usecases/register_usecase.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  });

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await loginUseCase(email, password);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await registerUseCase(name, email, password);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    _currentUser = null;
    notifyListeners();
  }
}