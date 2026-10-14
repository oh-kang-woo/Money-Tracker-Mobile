abstract class AnalyticsRemoteDataSource {
  Future<Map<String, double>> getMonthlyReport();
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  @override
  Future<Map<String, double>> getMonthlyReport() async {
    return {'Shopping': 37.94, 'Beauty': 21.86, 'Pet': 12.22};
  }
}