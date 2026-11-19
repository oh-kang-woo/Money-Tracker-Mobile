import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/transaction_model.dart';

class PdfReportExporter {
  static Future<void> exportMonthlyReport({
    required List<TransactionModel> transactions,
    required String monthLabel,
    required String userName,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryTotals = {};

    for (final trx in transactions) {
      if (trx.type == 'income') {
        totalIncome += trx.amount;
      } else if (trx.type == 'expense') {
        totalExpense += trx.amount;
        categoryTotals[trx.category] =
            (categoryTotals[trx.category] ?? 0) + trx.amount;
      }
    }

    final netBalance = totalIncome - totalExpense;
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final now = DateTime.now();
    final printedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // HEADER LAPORAN
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue900,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'LAPORAN KEUANGAN BULANAN',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Periode: $monthLabel',
                        style: const pw.TextStyle(
                          color: PdfColors.blue100,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        userName,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Dicetak: $printedDate',
                        style: const pw.TextStyle(
                          color: PdfColors.blue100,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // RINGKASAN SALDO
            pw.Row(
              children: [
                _summaryBox(
                  'Total Pemasukan',
                  currencyFormat.format(totalIncome),
                  PdfColors.green800,
                ),
                pw.SizedBox(width: 10),
                _summaryBox(
                  'Total Pengeluaran',
                  currencyFormat.format(totalExpense),
                  PdfColors.red800,
                ),
                pw.SizedBox(width: 10),
                _summaryBox(
                  'Selisih Bersih',
                  currencyFormat.format(netBalance),
                  PdfColors.blue800,
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // TABEL PENGELUARAN PER KATEGORI
            if (sortedCategories.isNotEmpty) ...[
              pw.Text(
                'Ringkasan Pengeluaran per Kategori',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                headers: ['Kategori', 'Total Pengeluaran', 'Persentase'],
                data: sortedCategories.map((e) {
                  final pct =
                      totalExpense > 0 ? (e.value / totalExpense) * 100 : 0.0;
                  return [
                    e.key,
                    currencyFormat.format(e.value),
                    '${pct.toStringAsFixed(1)}%',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // TABEL RINCIAN TRANSAKSI
            pw.Text(
              'Rincian Transaksi ($monthLabel)',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue900,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              headers: [
                'Tanggal',
                'Keterangan',
                'Kategori',
                'Dompet',
                'Tipe',
                'Nominal',
              ],
              data: transactions.map((trx) {
                final dateStr =
                    '${trx.date.day.toString().padLeft(2, '0')}/${trx.date.month.toString().padLeft(2, '0')}/${trx.date.year}';
                final typeLabel = trx.type == 'income'
                    ? 'Masuk'
                    : trx.type == 'expense'
                        ? 'Keluar'
                        : 'Transfer';
                return [
                  dateStr,
                  trx.title,
                  trx.category,
                  trx.type == 'transfer'
                      ? '${trx.wallet} -> ${trx.toWallet}'
                      : trx.wallet,
                  typeLabel,
                  currencyFormat.format(trx.amount),
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_${monthLabel.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _summaryBox(
    String title,
    String value,
    PdfColor valueColor,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}