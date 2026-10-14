import 'package:utsproject/features/analytics/data/datasources/analytics_remote_datasource.dart';

class GetMonthlyReport {
  final AnalyticsRemoteDataSource dataSource;
  GetMonthlyReport(this.dataSource);

  Future<Map<String, double>> call() => dataSource.getMonthlyReport();
}