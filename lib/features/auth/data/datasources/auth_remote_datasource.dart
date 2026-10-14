import 'package:utsproject/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel(id: 'u1', email: email, name: 'Jhon adrina');
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel(id: 'u2', email: email, name: name);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}