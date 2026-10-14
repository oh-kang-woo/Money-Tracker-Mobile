import 'package:utsproject/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:utsproject/features/auth/data/models/user_model.dart';
import 'package:utsproject/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;
  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<UserModel> login(String email, String password) => dataSource.login(email, password);

  @override
  Future<UserModel> register(String name, String email, String password) => dataSource.register(name, email, password);

  @override
  Future<void> logout() => dataSource.logout();
}