abstract class ProfileRemoteDataSource {
  Future<void> updateProfile(String name);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<void> updateProfile(String name) async {}
}