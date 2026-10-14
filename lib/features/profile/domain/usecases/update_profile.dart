import 'package:utsproject/features/profile/data/datasources/profile_remote_datasource.dart';

class UpdateProfile {
  final ProfileRemoteDataSource dataSource;
  UpdateProfile(this.dataSource);

  Future<void> call(String name) => dataSource.updateProfile(name);
}