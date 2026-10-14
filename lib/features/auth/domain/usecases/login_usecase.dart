import 'package:utsproject/features/auth/data/models/user_model.dart';
import 'package:utsproject/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserModel> call(String email, String password) => repository.login(email, password);
}