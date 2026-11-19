import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../controllers/bill_controller.dart';
import '../../../../controllers/saving_goal_controller.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../models/bill_model.dart';
import '../../../../models/saving_goal_model.dart';
import '../../../../models/transaction_model.dart';
import '../widgets/budget_progress_bar.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  void _showEditBudgetDialog(BuildContext context, double currentBudget) {
    final controller =
        TextEditingController(text: currentBudget.toInt().toString());
    final authController = AuthController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Atur Anggaran Bulanan',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Batas Pengeluaran (Rp)',
            labelStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: () async {
              final val = double.tryParse(controller.text) ?? 0;
              if (val > 0) {
                await authController.updateMonthlyBudget(val);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalModal(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    DateTime deadline = DateTime.now().add(const Duration(days: 90));
    final goalController = SavingGoalController();

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Buat Target Tabungan Baru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nama Target (Misal: Dana Darurat, Laptop)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
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
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Target Nominal (Rp)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.cardSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: deadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2040),
                      );
                      if (picked != null) {
                        setModalState(() => deadline = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event,
                            size: 18,
                            color: AppColors.purpleAccent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Target Tercapai: ${deadline.day}/${deadline.month}/${deadline.year}',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purpleAccent,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final target = double.tryParse(targetController.text) ?? 0;
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (title.isEmpty || target <= 0 || uid == null) return;

                      await goalController.addGoal(
                        SavingGoalModel(
                          userId: uid,
                          title: title,
                          targetAmount: target,
                          deadline: deadline,
                        ),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Simpan Target',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFundsDialog(BuildContext context, SavingGoalModel goal) {
    final amountController = TextEditingController();
    final goalController = SavingGoalController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Nabung: ${goal.title}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Nominal Setoran (Rp)',
            labelStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.incomeGreen,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: () async {
              final val = double.tryParse(amountController.text) ?? 0;
              if (val > 0 && goal.id != null) {
                await goalController.addFunds(goal.id!, val);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showAddBillModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dueDayController = TextEditingController(text: '10');
    String selectedWallet = 'Bank';
    final billController = BillController();

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tambah Tagihan Rutin Bulanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nama Tagihan (Misal: WiFi, Kos, Listrik)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
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
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nominal Tagihan (Rp)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
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
                        child: TextField(
                          controller: dueDayController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Tgl Jatuh Tempo (1-31)',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
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
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedWallet,
                          dropdownColor: AppColors.cardSecondary,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Sumber Dana',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.cardSecondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: TransactionModel.wallets.map((w) {
                            return DropdownMenuItem(value: w, child: Text(w));
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
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warningYellow,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final amount = double.tryParse(amountController.text) ?? 0;
                      final dueDay =
                          (int.tryParse(dueDayController.text) ?? 1).clamp(1, 31);
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (title.isEmpty || amount <= 0 || uid == null) return;

                      await billController.addBill(
                        BillModel(
                          userId: uid,
                          title: title,
                          amount: amount,
                          wallet: selectedWallet,
                          dueDay: dueDay,
                        ),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Simpan Tagihan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();
    final trxController = TransactionController();
    final goalController = SavingGoalController();
    final billController = BillController();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final now = DateTime.now();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Perencanaan Keuangan'),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryBlue,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Anggaran'),
              Tab(text: 'Tabungan'),
              Tab(text: 'Tagihan Rutin'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: ANGGARAN BULANAN
            StreamBuilder<DocumentSnapshot>(
              stream: authController.getUserProfileStream(),
              builder: (context, userSnap) {
                final userData =
                    userSnap.data?.data() as Map<String, dynamic>? ?? {};
                final monthlyBudget =
                    (userData['monthlyBudget'] ?? 2000000).toDouble();

                return StreamBuilder<List<TransactionModel>>(
                  stream: trxController.getTransactionsStream(),
                  builder: (context, trxSnap) {
                    final allTrx = trxSnap.data ?? [];
                    final monthlyExpense = allTrx
                        .where((t) =>
                            t.type == 'expense' &&
                            t.date.month == now.month &&
                            t.date.year == now.year)
                        .fold<double>(0, (acc, t) => acc + t.amount);

                    final ratio = monthlyBudget > 0
                        ? (monthlyExpense / monthlyBudget)
                        : 0.0;
                    final remaining = monthlyBudget - monthlyExpense;

                    Color barColor = AppColors.incomeGreen;
                    String statusText = 'Anggaran masih aman.';
                    if (ratio >= 1.0) {
                      barColor = AppColors.expenseRed;
                      statusText =
                          'Peringatan: Pengeluaran melebihi batas anggaran!';
                    } else if (ratio >= 0.8) {
                      barColor = AppColors.warningYellow;
                      statusText =
                          'Hati-hati: Pemakaian sudah mencapai 80% lebih.';
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Periode ${now.month}/${now.year}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppColors.primaryBlue,
                                      ),
                                      onPressed: () => _showEditBudgetDialog(
                                          context, monthlyBudget),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Terpakai: ${currencyFormat.format(monthlyExpense)}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Dari batas: ${currencyFormat.format(monthlyBudget)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                BudgetProgressBar(
                                    percentage: ratio, color: barColor),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(ratio * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: barColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      remaining >= 0
                                          ? 'Sisa: ${currencyFormat.format(remaining)}'
                                          : 'Over: ${currencyFormat.format(remaining.abs())}',
                                      style: TextStyle(
                                        color: remaining >= 0
                                            ? AppColors.textPrimary
                                            : AppColors.expenseRed,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  statusText,
                                  style:
                                      TextStyle(color: barColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // TAB 2: TARGET TABUNGAN
            Scaffold(
              backgroundColor: Colors.transparent,
              body: StreamBuilder<List<SavingGoalModel>>(
                stream: goalController.getGoalsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final goals = snapshot.data ?? [];
                  if (goals.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada target tabungan.\nTekan tombol + di bawah untuk membuat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      final ratio = goal.targetAmount > 0
                          ? (goal.currentAmount / goal.targetAmount)
                          : 0.0;
                      final isCompleted = ratio >= 1.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.incomeGreen
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.purpleAccent
                                      .withValues(alpha: 0.2),
                                  child: const Icon(
                                    Icons.flag_rounded,
                                    size: 18,
                                    color: AppColors.purpleAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Target: ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (goal.id != null) {
                                      goalController.deleteGoal(goal.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            BudgetProgressBar(
                              percentage: ratio,
                              color: isCompleted
                                  ? AppColors.incomeGreen
                                  : AppColors.purpleAccent,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${currencyFormat.format(goal.currentAmount)} / ${currencyFormat.format(goal.targetAmount)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(ratio * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: isCompleted
                                        ? AppColors.incomeGreen
                                        : AppColors.purpleAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.incomeGreen,
                                  side: const BorderSide(
                                      color: AppColors.incomeGreen),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    _showAddFundsDialog(context, goal),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Tambah Setoran Tabungan'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.purpleAccent,
                foregroundColor: AppColors.textPrimary,
                onPressed: () => _showAddGoalModal(context),
                child: const Icon(Icons.add),
              ),
            ),

            // TAB 3: TAGIHAN RUTIN BULANAN
            Scaffold(
              backgroundColor: Colors.transparent,
              body: StreamBuilder<List<BillModel>>(
                stream: billController.getBillsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final bills = snapshot.data ?? [];
                  if (bills.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada tagihan rutin.\nTekan tombol + untuk mencatat WiFi, Listrik, Kos, dll.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      final isPaid = bill.isPaidForMonth(now);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isPaid
                                ? AppColors.incomeGreen.withValues(alpha: 0.5)
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: (isPaid
                                      ? AppColors.incomeGreen
                                      : AppColors.warningYellow)
                                  .withValues(alpha: 0.18),
                              child: Icon(
                                isPaid
                                    ? Icons.check_circle_outline
                                    : Icons.notifications_active_outlined,
                                color: isPaid
                                    ? AppColors.incomeGreen
                                    : AppColors.warningYellow,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bill.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tgl ${bill.dueDay} tiap bulan • ${bill.wallet}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(bill.amount),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isPaid)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.incomeGreen
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Lunas',
                                  style: TextStyle(
                                    color: AppColors.incomeGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: AppColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  await billController.payBill(bill);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${bill.title} berhasil dibayar & dicatat!',
                                        ),
                                        backgroundColor: AppColors.incomeGreen,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Bayar',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                if (bill.id != null) {
                                  billController.deleteBill(bill.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.warningYellow,
                foregroundColor: AppColors.background,
                onPressed: () => _showAddBillModal(context),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}