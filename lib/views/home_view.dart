import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/config/app_colors.dart';
import '../controllers/category_controller.dart';
import '../controllers/transaction_controller.dart';
import '../core/services/privacy_service.dart';
import '../features/transaction/presentation/widgets/transaction_card.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../shared/widgets/amount_calculator.dart';
import '../shared/widgets/month_selector.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TransactionController _controller = TransactionController();
  final CategoryController _categoryController = CategoryController();
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _selectedFilter = 'all';
  String _selectedWalletFilter = 'Semua';
  String _searchQuery = '';

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  IconData _resolveCategoryIcon(
    String categoryName,
    List<CategoryModel> customCategories,
  ) {
    final custom = customCategories.where((c) => c.name == categoryName);
    if (custom.isNotEmpty) {
      return CategoryModel.getIconByKey(custom.first.iconKey);
    }
    return TransactionModel.getCategoryIcon(categoryName);
  }

  void _showAddCustomCategoryDialog(
    BuildContext context, {
    required String initialType,
    required ValueChanged<String> onCreated,
  }) {
    final nameController = TextEditingController();
    String selectedType = initialType;
    String selectedIconKey = 'coffee';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Buat Kategori Kustom',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('Keluar')),
                      ButtonSegment(value: 'income', label: Text('Masuk')),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (val) {
                      setDialogState(() => selectedType = val.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Nama Kategori (Misal: Kopi, Skincare)',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pilih Ikon:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryModel.iconOptions.entries.map((entry) {
                      final isSelected = selectedIconKey == entry.key;
                      return InkWell(
                        onTap: () {
                          setDialogState(() => selectedIconKey = entry.key);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.cardSecondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            entry.value,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
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
                  final name = nameController.text.trim();
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (name.isEmpty || uid == null) return;

                  await _categoryController.addCategory(
                    CategoryModel(
                      userId: uid,
                      name: name,
                      type: selectedType,
                      iconKey: selectedIconKey,
                    ),
                  );
                  onCreated(name);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTransactionModal(
    BuildContext context, {
    TransactionModel? existingTrx,
    required List<CategoryModel> customCategories,
  }) {
    final titleController =
        TextEditingController(text: existingTrx?.title ?? '');
    
    // Perbaikan M-03: Menjaga angka desimal jika ada
    final amountController = TextEditingController(
      text: existingTrx != null 
          ? (existingTrx.amount % 1 == 0 
              ? existingTrx.amount.toInt().toString() 
              : existingTrx.amount.toString()) 
          : '',
    );
    String selectedType = existingTrx?.type ?? 'expense';
    String selectedCategory = existingTrx?.category ?? 'Makanan';
    String selectedWallet = existingTrx?.wallet ?? 'Tunai';
    DateTime selectedDate = existingTrx?.date ?? DateTime.now();
    bool showCalculator = false;
    bool isSubmitting = false; // M-06
    List<CategoryModel> localCustomCats = List.from(customCategories);

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
            final baseCategories = selectedType == 'income'
                ? TransactionModel.incomeCategories
                : TransactionModel.expenseCategories;
            final extraCategories = localCustomCats
                .where((c) => c.type == selectedType)
                .map((c) => c.name)
                .toList();
            final categories = {...baseCategories, ...extraCategories}.toList();

            if (!categories.contains(selectedCategory)) {
              selectedCategory = categories.first;
            }

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
                    Text(
                      existingTrx == null
                          ? 'Tambah Transaksi'
                          : 'Edit Transaksi',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'expense',
                          label: Text('Pengeluaran'),
                        ),
                        ButtonSegment(
                          value: 'income',
                          label: Text('Pemasukan'),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (val) {
                        setModalState(() {
                          selectedType = val.first;
                          selectedCategory = selectedType == 'income'
                              ? TransactionModel.incomeCategories.first
                              : TransactionModel.expenseCategories.first;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCategory,
                            dropdownColor: AppColors.cardSecondary,
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Kategori',
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
                            items: categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Row(
                                  children: [
                                    Icon(
                                      _resolveCategoryIcon(
                                          cat, localCustomCats),
                                      size: 16,
                                      color: AppColors.primaryBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        cat,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedCategory = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Tambah Kategori Kustom',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.cardSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.neonCyan,
                          ),
                          onPressed: () {
                            _showAddCustomCategoryDialog(
                              ctx,
                              initialType: selectedType,
                              onCreated: (newName) {
                                final uid =
                                    FirebaseAuth.instance.currentUser?.uid ??
                                        '';
                                setModalState(() {
                                  localCustomCats.add(
                                    CategoryModel(
                                      userId: uid,
                                      name: newName,
                                      type: selectedType,
                                    ),
                                  );
                                  selectedCategory = newName;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 6),
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
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Keterangan',
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
                          child: TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Kalkulator Nominal',
                          style: IconButton.styleFrom(
                            backgroundColor: showCalculator
                                ? AppColors.primaryBlue
                                : AppColors.cardSecondary,
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.calculate_outlined,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {
                            setModalState(
                                () => showCalculator = !showCalculator);
                          },
                        ),
                      ],
                    ),
                    if (showCalculator)
                      AmountCalculator(
                        initialValue: amountController.text,
                        onResultChanged: (val) {
                          amountController.text = val;
                        },
                      ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
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
                              Icons.calendar_today,
                              size: 18,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Tanggal: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style:
                                  const TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting ? null : () async {
                        final title = titleController.text.trim();
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (title.isEmpty || amount <= 0 || uid == null) return;

                        final trx = TransactionModel(
                          id: existingTrx?.id,
                          userId: uid,
                          title: title,
                          amount: amount,
                          type: selectedType,
                          category: selectedCategory,
                          wallet: selectedWallet,
                          date: selectedDate,
                        );

                        setModalState(() => isSubmitting = true); // M-06

                        try {
                          if (existingTrx == null) {
                            await _controller.addTransaction(trx);
                          } else {
                            await _controller.updateTransaction(trx);
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
                            );
                          }
                        } finally {
                          if (ctx.mounted) setModalState(() => isSubmitting = false);
                        }
                      },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : Text(
                              existingTrx == null
                                  ? 'Simpan Transaksi'
                                  : 'Update Transaksi',
                              style: const TextStyle(fontWeight: FontWeight.bold),
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

  void _showTransferModal(
    BuildContext context, {
    TransactionModel? existingTrx,
    required List<TransactionModel> allTransactions,
  }) {
    String fromWallet = existingTrx?.wallet ?? 'Bank';
    String toWallet = existingTrx?.toWallet ?? 'Tunai';
    final noteController =
        TextEditingController(text: existingTrx?.title ?? '');
    
    // Perbaikan M-03: Menjaga angka desimal jika ada
    final amountController = TextEditingController(
      text: existingTrx != null 
          ? (existingTrx.amount % 1 == 0 
              ? existingTrx.amount.toInt().toString() 
              : existingTrx.amount.toString()) 
          : '',
    );
    DateTime selectedDate = existingTrx?.date ?? DateTime.now();
    bool isSubmitting = false; // M-06

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
                      'Transfer Antar Dompet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: fromWallet,
                            dropdownColor: AppColors.cardSecondary,
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Dari Dompet',
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
                              return DropdownMenuItem(value: w, child: Text(w));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => fromWallet = val);
                              }
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward,
                            color: AppColors.neonCyan,
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: toWallet,
                            dropdownColor: AppColors.cardSecondary,
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Ke Dompet',
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
                              return DropdownMenuItem(value: w, child: Text(w));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => toWallet = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Nominal Transfer (Rp)',
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
                      controller: noteController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        hintText: 'Misal: Tarik tunai ATM / Top up',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
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
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting ? null : () async {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (amount <= 0 || uid == null || fromWallet == toWallet) {
                          return;
                        }

                        // Perbaikan M-02: Validasi ketersediaan saldo sebelum transfer
                        double currentBalance = 0;
                        for (final t in allTransactions) {
                          if (t.wallet == fromWallet) {
                            if (t.type == 'income') currentBalance += t.amount;
                            if (t.type == 'expense' || t.type == 'transfer') currentBalance -= t.amount;
                          }
                          if (t.type == 'transfer' && t.toWallet == fromWallet) {
                            currentBalance += t.amount;
                          }
                        }

                        // Jangan memblokir mutlak jika ini hanya edit transaksi (karena saldo sudah terpengaruh sebelumnya)
                        // Namun untuk transaksi baru, validasi saldo sangat penting
                        if (existingTrx == null && amount > currentBalance) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.expenseRed,
                              content: Text(
                                'Saldo dompet $fromWallet tidak mencukupi (Sisa: ${PrivacyService.formatCurrency(currentBalance, _currencyFormat, false)})',
                              ),
                            ),
                          );
                          return;
                        }

                        final title = noteController.text.trim().isEmpty
                            ? 'Transfer $fromWallet → $toWallet'
                            : noteController.text.trim();

                        final trx = TransactionModel(
                          id: existingTrx?.id,
                          userId: uid,
                          title: title,
                          amount: amount,
                          type: 'transfer',
                          category: 'Transfer',
                          wallet: fromWallet,
                          toWallet: toWallet,
                          date: selectedDate,
                        );

                        setModalState(() => isSubmitting = true); // M-06

                        try {
                          if (existingTrx == null) {
                            await _controller.addTransaction(trx);
                          } else {
                            await _controller.updateTransaction(trx);
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Gagal memproses transfer: $e')),
                            );
                          }
                        } finally {
                          if (ctx.mounted) setModalState(() => isSubmitting = false);
                        }
                      },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.background),
                            )
                          : const Text(
                              'Proses Transfer',
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

  Widget _buildWalletRow(
    List<TransactionModel> allTransactions,
    bool isHidden,
  ) {
    final Map<String, double> walletBalances = {
      'Tunai': 0,
      'Bank': 0,
      'E-Wallet': 0,
    };

    for (final t in allTransactions) {
      if (t.type == 'income' && walletBalances.containsKey(t.wallet)) {
        walletBalances[t.wallet] = walletBalances[t.wallet]! + t.amount;
      } else if (t.type == 'expense' && walletBalances.containsKey(t.wallet)) {
        walletBalances[t.wallet] = walletBalances[t.wallet]! - t.amount;
      } else if (t.type == 'transfer') {
        if (walletBalances.containsKey(t.wallet)) {
          walletBalances[t.wallet] = walletBalances[t.wallet]! - t.amount;
        }
        if (t.toWallet != null && walletBalances.containsKey(t.toWallet)) {
          walletBalances[t.toWallet!] = walletBalances[t.toWallet!]! + t.amount;
        }
      }
    }

    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: TransactionModel.wallets.map((wallet) {
          final isSelected = _selectedWalletFilter == wallet;
          final balance = walletBalances[wallet] ?? 0;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWalletFilter = isSelected ? 'Semua' : wallet;
              });
            },
            child: Container(
              width: 145,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.25)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        TransactionModel.getWalletIcon(wallet),
                        size: 15,
                        color: AppColors.neonCyan,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        wallet,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    PrivacyService.formatCurrency(
                      balance,
                      _currencyFormat,
                      isHidden,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard(
    double totalIncome,
    double totalExpense,
    double prevMonthExpense,
    String topCategoryLabel,
    bool isHidden,
  ) {
    final balance = totalIncome - totalExpense;

    String insightText = 'Belum ada perbandingan bulan lalu';
    Color insightColor = AppColors.textSecondary;
    IconData insightIcon = Icons.insights;

    if (prevMonthExpense > 0) {
      final diffPct =
          ((totalExpense - prevMonthExpense) / prevMonthExpense) * 100;
      if (diffPct <= 0) {
        insightText =
            'Hemat ${diffPct.abs().toStringAsFixed(0)}% dibanding bulan lalu';
        insightColor = AppColors.incomeGreen;
        insightIcon = Icons.trending_down;
      } else {
        insightText =
            'Pengeluaran naik ${diffPct.toStringAsFixed(0)}% dari bulan lalu';
        insightColor = AppColors.warningYellow;
        insightIcon = Icons.trending_up;
      }
    } else if (totalExpense > 0) {
      insightText = topCategoryLabel;
      insightColor = AppColors.neonCyan;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.cardSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selisih Bulan Ini',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(insightIcon, size: 13, color: insightColor),
                    const SizedBox(width: 5),
                    Text(
                      insightText,
                      style: TextStyle(
                        color: insightColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            PrivacyService.formatCurrency(balance, _currencyFormat, isHidden),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  label: 'Pemasukan',
                  value: PrivacyService.formatCurrency(
                    totalIncome,
                    _currencyFormat,
                    isHidden,
                  ),
                  icon: Icons.arrow_downward,
                  color: AppColors.incomeGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  label: 'Pengeluaran',
                  value: PrivacyService.formatCurrency(
                    totalExpense,
                    _currencyFormat,
                    isHidden,
                  ),
                  icon: Icons.arrow_upward,
                  color: AppColors.expenseRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PrivacyService.isHiddenNotifier,
      builder: (context, isHidden, _) {
        return StreamBuilder<List<CategoryModel>>(
          stream: _categoryController.getCategoriesStream(),
          builder: (context, catSnap) {
            final customCategories = catSnap.data ?? [];

            return StreamBuilder<List<TransactionModel>>(
              stream: _controller.getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Error memuat data: ${snapshot.error}',
                        style: const TextStyle(color: AppColors.expenseRed),
                      ),
                    ),
                  );
                }

                final allTransactions = snapshot.data ?? [];

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Money Tracker'),
                    actions: [
                      IconButton(
                        tooltip: isHidden ? 'Tampilkan Saldo' : 'Sembunyikan Saldo',
                        icon: Icon(
                          isHidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => PrivacyService.togglePrivacy(),
                      ),
                      IconButton(
                        tooltip: 'Transfer Antar Dompet',
                        icon: const Icon(Icons.swap_horiz, color: AppColors.neonCyan),
                        // Menambahkan passing parameter allTransactions
                        onPressed: () => _showTransferModal(context, allTransactions: allTransactions),
                      ),
                    ],
                  ),
                  body: Builder(
                    builder: (context) {
                      final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);

                      final monthlyTransactions = allTransactions.where((t) {
                        return t.date.month == _selectedMonth.month &&
                            t.date.year == _selectedMonth.year;
                      }).toList();

                      final double prevMonthExpense = allTransactions
                          .where((t) =>
                              t.type == 'expense' &&
                              t.date.month == prevMonth.month &&
                              t.date.year == prevMonth.year)
                          .fold<double>(0, (acc, t) => acc + t.amount);

                      double totalIncome = 0;
                      double totalExpense = 0;
                      final Map<String, double> catMap = {};

                      for (final t in monthlyTransactions) {
                        if (t.type == 'income') {
                          totalIncome += t.amount;
                        } else if (t.type == 'expense') {
                          totalExpense += t.amount;
                          catMap[t.category] =
                              (catMap[t.category] ?? 0) + t.amount;
                        }
                      }

                      String topCategoryLabel = 'Terbesar: -';
                      if (catMap.isNotEmpty && totalExpense > 0) {
                        final topEntry = catMap.entries
                            .reduce((a, b) => a.value > b.value ? a : b);
                        final pct = (topEntry.value / totalExpense) * 100;
                        topCategoryLabel =
                            'Terbesar: ${topEntry.key} (${pct.toStringAsFixed(0)}%)';
                      }

                      final filteredTransactions = monthlyTransactions.where((t) {
                        final matchesFilter =
                            _selectedFilter == 'all' || t.type == _selectedFilter;
                        final matchesWallet = _selectedWalletFilter == 'Semua' ||
                            t.wallet == _selectedWalletFilter ||
                            (t.type == 'transfer' &&
                                t.toWallet == _selectedWalletFilter);
                        final matchesSearch = t.title
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            t.category
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase());
                        return matchesFilter && matchesWallet && matchesSearch;
                      }).toList();

                      return Column(
                        children: [
                          MonthSelector(
                            selectedMonth: _selectedMonth,
                            onMonthChanged: (newMonth) {
                              setState(() => _selectedMonth = newMonth);
                            },
                          ),
                          _buildSummaryCard(
                            totalIncome,
                            totalExpense,
                            prevMonthExpense,
                            topCategoryLabel,
                            isHidden,
                          ),
                          _buildWalletRow(allTransactions, isHidden),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val),
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Cari transaksi atau kategori...',
                                hintStyle:
                                    const TextStyle(color: AppColors.textMuted),
                                prefixIcon: const Icon(Icons.search,
                                    color: AppColors.textMuted),
                                filled: true,
                                fillColor: AppColors.cardBackground,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      const BorderSide(color: AppColors.cardBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      const BorderSide(color: AppColors.cardBorder),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                _buildFilterChip('Semua', 'all'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Pemasukan', 'income'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Pengeluaran', 'expense'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Transfer', 'transfer'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: filteredTransactions.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Tidak ada transaksi pada filter ini.',
                                      style:
                                          TextStyle(color: AppColors.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                    itemCount: filteredTransactions.length,
                                    itemBuilder: (context, index) {
                                      final trx = filteredTransactions[index];
                                      final isIncome = trx.type == 'income';
                                      final isTransfer = trx.type == 'transfer';

                                      return Dismissible(
                                        key: ValueKey(
                                            trx.id ?? '$index-${trx.title}'),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.only(right: 20),
                                          alignment: Alignment.centerRight,
                                          decoration: BoxDecoration(
                                            color: AppColors.expenseRed,
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          child: const Icon(
                                            Icons.delete_sweep,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        onDismissed: (_) async {
                                          if (trx.id != null) {
                                            await _controller
                                                .deleteTransaction(trx.id!);
                                          }
                                        },
                                        child: TransactionCard(
                                          title: trx.title,
                                          date: isTransfer
                                              ? '${trx.wallet} → ${trx.toWallet} • ${trx.date.day}/${trx.date.month}/${trx.date.year}'
                                              : '${trx.category} • ${trx.wallet} • ${trx.date.day}/${trx.date.month}/${trx.date.year}',
                                          amount: isTransfer
                                              ? PrivacyService.formatCurrency(
                                                  trx.amount,
                                                  _currencyFormat,
                                                  isHidden,
                                                  prefix: '⇄ ',
                                                )
                                              : PrivacyService.formatCurrency(
                                                  trx.amount,
                                                  _currencyFormat,
                                                  isHidden,
                                                  prefix: isIncome ? '+ ' : '- ',
                                                ),
                                          isPositive: isIncome,
                                          customColor: isTransfer
                                              ? AppColors.neonCyan
                                              : null,
                                          icon: _resolveCategoryIcon(
                                              trx.category, customCategories),
                                          onTap: () => isTransfer
                                              ? _showTransferModal(
                                                  context,
                                                  existingTrx: trx,
                                                  allTransactions: allTransactions, // pass transactions
                                                )
                                              : _showTransactionModal(
                                                  context,
                                                  existingTrx: trx,
                                                  customCategories:
                                                      customCategories,
                                                ),
                                          onDelete: () => _controller
                                              .deleteTransaction(trx.id!),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    }
                  ),
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.textPrimary,
                    onPressed: () => _showTransactionModal(
                      context,
                      customCategories: customCategories,
                    ),
                    child: const Icon(Icons.add),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      backgroundColor: AppColors.cardBackground,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }
}