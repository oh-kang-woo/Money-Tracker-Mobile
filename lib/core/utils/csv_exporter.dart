import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/transaction_model.dart';

class CsvExporter {
  static Future<void> exportTransactions(
    List<TransactionModel> transactions, {
    String fileName = 'laporan_keuangan.csv',
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Tanggal,Judul,Kategori,Dompet,Tipe,Nominal');

    for (final trx in transactions) {
      final dateStr =
          '${trx.date.year}-${trx.date.month.toString().padLeft(2, '0')}-${trx.date.day.toString().padLeft(2, '0')}';
      final cleanTitle = trx.title.replaceAll(',', ' ');
      final typeLabel = trx.type == 'income' ? 'Pemasukan' : 'Pengeluaran';
      buffer.writeln(
        '$dateStr,$cleanTitle,${trx.category},${trx.wallet},$typeLabel,${trx.amount.toInt()}',
      );
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(buffer.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Laporan Transaksi Money Tracker',
      ),
    );
  }
}