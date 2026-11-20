import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/utils/pdf_report_exporter.dart';
import '../../../../models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _periodType = 'monthly'; // 'daily', 'weekly', 'monthly'
  DateTime _selectedDate = DateTime.now();
  List<TransactionModel> _filteredPeriodTransactions = [];

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

  static const List<String> _shortDays = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min',
  ];

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _startOfWeek(DateTime d) {
    final clean = _dateOnly(d);
    return clean.subtract(Duration(days: clean.weekday - 1));
  }

  DateTime _endOfWeek(DateTime d) {
    return _startOfWeek(d).add(const Duration(days: 6));
  }

  String _getPeriodLabel() {
    if (_periodType == 'daily') {
      return '${_selectedDate.day} ${_fullMonths[_selectedDate.month - 1]} ${_selectedDate.year}';
    } else if (_periodType == 'weekly') {
      final start = _startOfWeek(_selectedDate);
      final end = _endOfWeek(_selectedDate);
      if (start.month == end.month) {
        return '${start.day} - ${end.day} ${_shortMonths[end.month - 1]} ${end.year}';
      }
      return '${start.day} ${_shortMonths[start.month - 1]} - ${end.day} ${_shortMonths[end.month - 1]} ${end.year}';
    }
    return '${_fullMonths[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  String _getExportFileName(String ext) {
    if (_periodType == 'daily') {
      return 'laporan_harian_${_selectedDate.day}_${_selectedDate.month}_${_selectedDate.year}.$ext';
    } else if (_periodType == 'weekly') {
      final start = _startOfWeek(_selectedDate);
      return 'laporan_mingguan_${start.day}_${start.month}_${start.year}.$ext';
    }
    return 'laporan_bulanan_${_selectedDate.month}_${_selectedDate.year}.$ext';
  }

  void _shiftPeriod(int step) {
    setState(() {
      if (_periodType == 'daily') {
        _selectedDate = _selectedDate.add(Duration(days: step));
      } else if (_periodType == 'weekly') {
        _selectedDate = _selectedDate.add(Duration(days: 7 * step));
      } else {
        _selectedDate =
            DateTime(_selectedDate.year, _selectedDate.month + step, 1);
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildPeriodNavigator() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () => _shiftPeriod(-1),
          ),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPeriodLabel(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: () => _shiftPeriod(1),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSummaryCard(
    double totalIncome,
    double totalExpense,
    NumberFormat currencyFormat,
  ) {
    final net = totalIncome - totalExpense;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _miniStatItem(
              'Pemasukan',
              currencyFormat.format(totalIncome),
              AppColors.incomeGreen,
            ),
          ),
          Container(width: 1, height: 34, color: AppColors.cardBorder),
          Expanded(
            child: _miniStatItem(
              'Pengeluaran',
              currencyFormat.format(totalExpense),
              AppColors.expenseRed,
            ),
          ),
          Container(width: 1, height: 34, color: AppColors.cardBorder),
          Expanded(
            child: _miniStatItem(
              'Selisih',
              currencyFormat.format(net),
              net >= 0 ? AppColors.neonCyan : AppColors.warningYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStatItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBarChart(List<TransactionModel> allTransactions) {
    String chartTitle = 'Tren 6 Bulan Terakhir';
    final List<String> labels = [];
    final List<double> incomes = [];
    final List<double> expenses = [];

    if (_periodType == 'daily') {
      chartTitle = 'Tren 7 Hari Terakhir';
      final baseDay = _dateOnly(_selectedDate);
      for (int i = 6; i >= 0; i--) {
        final d = baseDay.subtract(Duration(days: i));
        labels.add('${d.day}/${d.month}');
        double inc = 0;
        double exp = 0;
        for (final t in allTransactions) {
          if (t.date.year == d.year &&
              t.date.month == d.month &&
              t.date.day == d.day) {
            if (t.type == 'income') inc += t.amount;
            if (t.type == 'expense') exp += t.amount;
          }
        }
        incomes.add(inc);
        expenses.add(exp);
      }
    } else if (_periodType == 'weekly') {
      chartTitle = 'Rincian Harian Minggu Ini';
      final start = _startOfWeek(_selectedDate);
      for (int i = 0; i < 7; i++) {
        final d = start.add(Duration(days: i));
        labels.add(_shortDays[i]);
        double inc = 0;
        double exp = 0;
        for (final t in allTransactions) {
          if (t.date.year == d.year &&
              t.date.month == d.month &&
              t.date.day == d.day) {
            if (t.type == 'income') inc += t.amount;
            if (t.type == 'expense') exp += t.amount;
          }
        }
        incomes.add(inc);
        expenses.add(exp);
      }
    } else {
      chartTitle = 'Tren 6 Bulan Terakhir';
      final months = List.generate(6, (index) {
        return DateTime(_selectedDate.year, _selectedDate.month - (5 - index));
      });
      for (final m in months) {
        labels.add(_shortMonths[m.month - 1]);
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
      }
    }

    double maxVal = 0;
    for (int i = 0; i < labels.length; i++) {
      if (incomes[i] > maxVal) maxVal = incomes[i];
      if (expenses[i] > maxVal) maxVal = expenses[i];
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
              Text(
                chartTitle,
                style: const TextStyle(
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
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[idx],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(labels.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: incomes[i],
                        color: AppColors.incomeGreen,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: expenses[i],
                        color: AppColors.expenseRed,
                        width: 8,
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
    final periodLabel = _getPeriodLabel();

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
              if (_filteredPeriodTransactions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada data transaksi pada periode ini.'),
                  ),
                );
                return;
              }
              final user = FirebaseAuth.instance.currentUser;
              await PdfReportExporter.exportMonthlyReport(
                transactions: _filteredPeriodTransactions,
                monthLabel: periodLabel,
                userName: user?.displayName ?? user?.email ?? 'Pengguna',
              );
            },
          ),
          IconButton(
            tooltip: 'Export CSV Periode Ini',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () async {
              if (_filteredPeriodTransactions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada data transaksi pada periode ini.'),
                  ),
                );
                return;
              }
              await CsvExporter.exportTransactions(
                _filteredPeriodTransactions,
                fileName: _getExportFileName('csv'),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text('Per Hari')),
                ButtonSegment(value: 'weekly', label: Text('Per Minggu')),
                ButtonSegment(value: 'monthly', label: Text('Per Bulan')),
              ],
              selected: {_periodType},
              onSelectionChanged: (val) {
                setState(() => _periodType = val.first);
              },
            ),
          ),
          _buildPeriodNavigator(),
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: controller.getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTransactions = snapshot.data ?? [];
                final startWeek = _startOfWeek(_selectedDate);
                final endWeek = _endOfWeek(_selectedDate);

                _filteredPeriodTransactions = allTransactions.where((t) {
                  if (_periodType == 'daily') {
                    return t.date.year == _selectedDate.year &&
                        t.date.month == _selectedDate.month &&
                        t.date.day == _selectedDate.day;
                  } else if (_periodType == 'weekly') {
                    final d = _dateOnly(t.date);
                    return !d.isBefore(startWeek) && !d.isAfter(endWeek);
                  }
                  return t.date.month == _selectedDate.month &&
                      t.date.year == _selectedDate.year;
                }).toList();

                double periodIncome = 0;
                double periodExpense = 0;
                final Map<String, double> categoryTotals = {};

                for (final item in _filteredPeriodTransactions) {
                  if (item.type == 'income') {
                    periodIncome += item.amount;
                  } else if (item.type == 'expense') {
                    periodExpense += item.amount;
                    categoryTotals[item.category] =
                        (categoryTotals[item.category] ?? 0) + item.amount;
                  }
                }

                final entries = categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Column(
                    children: [
                      _buildPeriodSummaryCard(
                        periodIncome,
                        periodExpense,
                        currencyFormat,
                      ),
                      const SizedBox(height: 14),
                      _buildTrendBarChart(allTransactions),
                      const SizedBox(height: 16),
                      if (entries.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Text(
                            'Belum ada pengeluaran pada periode ini.',
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
                                        (entry.value / periodExpense) * 100;
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
                                    currencyFormat.format(periodExpense),
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
                          final pct = (entry.value / periodExpense) * 100;

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