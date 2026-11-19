import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../controllers/debt_controller.dart';
import '../../../../models/debt_model.dart';
import '../../../../models/transaction_model.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  final DebtController _debtController = DebtController();
  String _filterType = 'all'; // 'all', 'payable', 'receivable'

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _showAddDebtModal(BuildContext context) {
    final personController = TextEditingController();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'payable';
    String selectedWallet = 'Tunai';
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    bool affectWalletNow = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Catat Hutang / Piutang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'payable',
                          label: Text('Hutang Saya'),
                        ),
                        ButtonSegment(
                          value: 'receivable',
                          label: Text('Piutang (Dipinjam)'),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (val) {
                        setModalState(() => selectedType = val.first);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: personController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: selectedType == 'payable'
                            ? 'Nama Pemberi Pinjaman'
                            : 'Nama Peminjam',
                        labelStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.cardSecondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Keperluan / Keterangan',
                        labelStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.cardSecondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Nominal (Rp)',
                              labelStyle: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.cardSecondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedWallet,
                            dropdownColor: AppColors.cardSecondary,
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Dompet',
                              labelStyle: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.cardSecondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: TransactionModel.wallets.map((w) {
                              return DropdownMenuItem(
                                value: w,
                                child: Text(
                                  w,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedWallet = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: dueDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setModalState(() => dueDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_available,
                              size: 18,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Jatuh Tempo: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                              style:
                                  const TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.primaryBlue,
                      title: const Text(
                        'Sesuaikan saldo dompet sekarang',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        selectedType == 'payable'
                            ? 'Otomatis tambah saldo $selectedWallet'
                            : 'Otomatis kurangi saldo $selectedWallet',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      value: affectWalletNow,
                      onChanged: (val) {
                        setModalState(() => affectWalletNow = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final person = personController.text.trim();
                        final title = titleController.text.trim();
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (person.isEmpty || amount <= 0 || uid == null) {
                          return;
                        }

                        await _debtController.addDebt(
                          DebtModel(
                            userId: uid,
                            personName: person,
                            title: title.isEmpty ? 'Pinjaman' : title,
                            amount: amount,
                            type: selectedType,
                            wallet: selectedWallet,
                            dueDate: dueDate,
                          ),
                          affectWalletNow: affectWalletNow,
                        );

                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Simpan Catatan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryHeader(double totalPayable, double totalReceivable) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.expenseRed.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Hutang Saya',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currencyFormat.format(totalPayable),
                    style: const TextStyle(
                      color: AppColors.expenseRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.incomeGreen.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Piutang',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currencyFormat.format(totalReceivable),
                    style: const TextStyle(
                      color: AppColors.incomeGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hutang & Piutang')),
      body: StreamBuilder<List<DebtModel>>(
        stream: _debtController.getDebtsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDebts = snapshot.data ?? [];
          double totalPayable = 0;
          double totalReceivable = 0;

          for (final d in allDebts) {
            if (!d.isPaid) {
              if (d.type == 'payable') {
                totalPayable += d.amount;
              } else {
                totalReceivable += d.amount;
              }
            }
          }

          final filteredDebts = allDebts.where((d) {
            if (_filterType == 'all') return true;
            return d.type == _filterType;
          }).toList();

          return Column(
            children: [
              _buildSummaryHeader(totalPayable, totalReceivable),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('Semua', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Hutang Saya', 'payable'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Piutang', 'receivable'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: filteredDebts.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada catatan hutang atau piutang.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: filteredDebts.length,
                        itemBuilder: (context, index) {
                          final debt = filteredDebts[index];
                          final isPayable = debt.type == 'payable';
                          final accent = isPayable
                              ? AppColors.expenseRed
                              : AppColors.incomeGreen;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: debt.isPaid
                                    ? AppColors.cardBorder
                                    : accent.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: (debt.isPaid
                                          ? AppColors.textMuted
                                          : accent)
                                      .withValues(alpha: 0.15),
                                  child: Icon(
                                    isPayable
                                        ? Icons.call_made_rounded
                                        : Icons.call_received_rounded,
                                    color: debt.isPaid
                                        ? AppColors.textMuted
                                        : accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        debt.personName,
                                        style: TextStyle(
                                          color: debt.isPaid
                                              ? AppColors.textSecondary
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          decoration: debt.isPaid
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${debt.title} • Tempo ${debt.dueDate.day}/${debt.dueDate.month}/${debt.dueDate.year}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_currencyFormat.format(debt.amount)} (${debt.wallet})',
                                        style: TextStyle(
                                          color: debt.isPaid
                                              ? AppColors.textMuted
                                              : accent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (debt.isPaid)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardSecondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Lunas',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: AppColors.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      await _debtController.settleDebt(debt);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Catatan dengan ${debt.personName} dilunasi!',
                                            ),
                                            backgroundColor:
                                                AppColors.incomeGreen,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Lunasi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (debt.id != null) {
                                      _debtController.deleteDebt(debt.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textPrimary,
        onPressed: () => _showAddDebtModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      backgroundColor: AppColors.cardBackground,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _filterType = value),
    );
  }
}