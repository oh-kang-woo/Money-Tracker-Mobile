import 'package:utsproject/features/auth/data/models/user_model.dart';
import 'package:utsproject/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<UserModel> call(String name, String email, String password) => repository.register(name, email, password);
}