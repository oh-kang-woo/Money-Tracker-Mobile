import 'package:flutter/material.dart';
import 'package:utsproject/features/analytics/domain/usecases/get_monthly_report.dart';

class AnalyticsController extends ChangeNotifier {
  final GetMonthlyReport getMonthlyReport;
  AnalyticsController({required this.getMonthlyReport});

  Map<String, double> report = {};

  Future<void> loadReport() async {
    report = await getMonthlyReport();
    notifyListeners();
  }
}