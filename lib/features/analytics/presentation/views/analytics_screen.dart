import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/utils/pdf_report_exporter.dart';
import '../../../../models/transaction_model.dart';
import '../../../../shared/widgets/month_selector.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<TransactionModel> _monthlyAllTransactions = [];

  static const List<Color> _chartColors = [
    AppColors.primaryBlue,
    AppColors.expenseRed,
    AppColors.incomeGreen,
    AppColors.warningYellow,
    AppColors.purpleAccent,
    AppColors.neonCyan,
  ];

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const List<String> _fullMonths = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  Widget _buildSixMonthBarChart(List<TransactionModel> allTransactions) {
    final List<DateTime> months = List.generate(6, (index) {
      return DateTime(_selectedMonth.year, _selectedMonth.month - (5 - index));
    });

    double maxVal = 0;
    final List<double> incomes = [];
    final List<double> expenses = [];

    for (final m in months) {
      double inc = 0;
      double exp = 0;
      for (final t in allTransactions) {
        if (t.date.month == m.month && t.date.year == m.year) {
          if (t.type == 'income') inc += t.amount;
          if (t.type == 'expense') exp += t.amount;
        }
      }
      incomes.add(inc);
      expenses.add(exp);
      if (inc > maxVal) maxVal = inc;
      if (exp > maxVal) maxVal = exp;
    }

    final topY = maxVal == 0 ? 100000.0 : maxVal * 1.25;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tren 6 Bulan Terakhir',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Row(
                children: [
                  _legendDot(AppColors.incomeGreen, 'Masuk'),
                  const SizedBox(width: 10),
                  _legendDot(AppColors.expenseRed, 'Keluar'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: topY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _shortMonths[months[idx].month - 1],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(6, (i) {
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: incomes[i],
                        color: AppColors.incomeGreen,
                        width: 9,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: expenses[i],
                        color: AppColors.expenseRed,
                        width: 9,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TransactionController();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final monthLabel =
        '${_fullMonths[_selectedMonth.month - 1]} ${_selectedMonth.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Keuangan'),
        actions: [
          IconButton(
            tooltip: 'Cetak / Simpan Laporan PDF',
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.expenseRed,
            ),
            onPressed: () async {
              if (_monthlyAllTransactions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada data transaksi di bulan ini.'),
                  ),
                );
                return;
              }
              final user = FirebaseAuth.instance.currentUser;
              await PdfReportExporter.exportMonthlyReport(
                transactions: _monthlyAllTransactions,
                monthLabel: monthLabel,
                userName: user?.displayName ?? user?.email ?? 'Pengguna',
              );
            },
          ),
          IconButton(
            tooltip: 'Export CSV Bulan Ini',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () async {
              if (_monthlyAllTransactions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada data transaksi di bulan ini.'),
                  ),
                );
                return;
              }
              await CsvExporter.exportTransactions(
                _monthlyAllTransactions,
                fileName:
                    'laporan_${_selectedMonth.month}_${_selectedMonth.year}.csv',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          MonthSelector(
            selectedMonth: _selectedMonth,
            onMonthChanged: (newMonth) {
              setState(() => _selectedMonth = newMonth);
            },
          ),
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: controller.getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTransactions = snapshot.data ?? [];
                _monthlyAllTransactions = allTransactions.where((t) {
                  return t.date.month == _selectedMonth.month &&
                      t.date.year == _selectedMonth.year;
                }).toList();

                final expenses = _monthlyAllTransactions
                    .where((t) => t.type == 'expense')
                    .toList();

                final Map<String, double> categoryTotals = {};
                double grandTotal = 0;
                for (final item in expenses) {
                  categoryTotals[item.category] =
                      (categoryTotals[item.category] ?? 0) + item.amount;
                  grandTotal += item.amount;
                }

                final entries = categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSixMonthBarChart(allTransactions),
                      const SizedBox(height: 16),
                      if (expenses.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Text(
                            'Belum ada pengeluaran di bulan ini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else ...[
                        Container(
                          height: 250,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 56,
                                  sections: List.generate(entries.length, (i) {
                                    final entry = entries[i];
                                    final pct =
                                        (entry.value / grandTotal) * 100;
                                    return PieChartSectionData(
                                      value: entry.value,
                                      color:
                                          _chartColors[i % _chartColors.length],
                                      title: '${pct.toStringAsFixed(0)}%',
                                      radius: 48,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Total Keluar',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(grandTotal),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(entries.length, (i) {
                          final entry = entries[i];
                          final color = _chartColors[i % _chartColors.length];
                          final pct = (entry.value / grandTotal) * 100;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: color.withValues(alpha: 0.2),
                                  child: Icon(
                                    TransactionModel.getCategoryIcon(entry.key),
                                    size: 16,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${pct.toStringAsFixed(1)}% dari total',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(entry.value),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}