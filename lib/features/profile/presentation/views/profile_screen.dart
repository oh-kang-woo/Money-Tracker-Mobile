import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../controllers/category_controller.dart';
import '../../../../controllers/debt_controller.dart';
import '../../../../controllers/saving_goal_controller.dart';
import '../../../../controllers/transaction_controller.dart';
import '../../../../core/services/app_lock_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/privacy_service.dart';
import '../../../../models/category_model.dart';
import '../../../../models/debt_model.dart';
import '../../../../models/saving_goal_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../auth/presentation/views/pin_lock_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = AuthController();
  final TransactionController _trxController = TransactionController();
  final SavingGoalController _goalController = SavingGoalController();
  final DebtController _debtController = DebtController();
  final CategoryController _categoryController = CategoryController();
  final AppLockService _lockService = AppLockService();
  final NotificationService _notificationService = NotificationService();

  bool _hasPin = false;
  bool _bioEnabled = false;
  bool _canUseBio = false;
  bool _dailyReminderEnabled = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hasPin = await _lockService.hasPin();
    final bioEnabled = await _lockService.isBiometricEnabled();
    final canBio = await _lockService.canUseBiometric();
    final reminderEnabled = await _notificationService.isDailyReminderEnabled();

    if (mounted) {
      setState(() {
        _hasPin = hasPin;
        _bioEnabled = bioEnabled;
        _canUseBio = canBio;
        _dailyReminderEnabled = reminderEnabled;
      });
    }
  }

  void _showEditNameDialog(String currentName) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Ubah Nama Profil',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
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
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                await _authController.updateDisplayName(newName);
                setState(() {});
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAndPreferencesCard(bool isHidden) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keamanan & Preferensi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primaryBlue,
            secondary: Icon(
              isHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.primaryBlue,
            ),
            title: const Text(
              'Mode Privasi Saldo',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
            subtitle: const Text(
              'Samarkan nominal uang menjadi Rp ••••••',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            value: isHidden,
            onChanged: (val) => PrivacyService.setPrivacy(val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.warningYellow,
            secondary: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.warningYellow,
            ),
            title: const Text(
              'Pengingat Catat Harian',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
            subtitle: const Text(
              'Notifikasi rutin harian & pengingat jatuh tempo',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            value: _dailyReminderEnabled,
            onChanged: (val) async {
              await _notificationService.setDailyReminderEnabled(val);
              await _loadSettings();
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await _notificationService.showInstantNotification(
                  title: 'Money Tracker Aktif',
                  body: 'Notifikasi pengingat keuangan berhasil terpasang!',
                );
              },
              icon: const Icon(Icons.send, size: 15),
              label: const Text(
                'Tes Notifikasi Sekarang',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const Divider(color: AppColors.cardBorder),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.pin_outlined, color: AppColors.primaryBlue),
            title: Text(
              _hasPin ? 'Ubah PIN 4-Digit' : 'Aktifkan Kunci PIN 4-Digit',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
            subtitle: Text(
              _hasPin ? 'Kunci aplikasi aktif' : 'Belum diatur',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: _hasPin
                ? TextButton(
                    onPressed: () async {
                      await _lockService.removePin();
                      await _loadSettings();
                    },
                    child: const Text(
                      'Matikan',
                      style: TextStyle(color: AppColors.expenseRed),
                    ),
                  )
                : const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
            onTap: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const PinLockScreen(isSetupMode: true),
                ),
              );
              if (created == true) {
                await _loadSettings();
              }
            },
          ),
          if (_hasPin && _canUseBio)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeTrackColor: AppColors.neonCyan,
              secondary: const Icon(
                Icons.fingerprint,
                color: AppColors.neonCyan,
              ),
              title: const Text(
                'Buka dengan Sidik Jari',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
              value: _bioEnabled,
              onChanged: (val) async {
                await _lockService.setBiometricEnabled(val);
                await _loadSettings();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCustomCategoriesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori Kustom Saya',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<CategoryModel>>(
            stream: _categoryController.getCategoriesStream(),
            builder: (context, snapshot) {
              final cats = snapshot.data ?? [];
              if (cats.isEmpty) {
                return const Text(
                  'Belum ada kategori kustom. Tambahkan lewat tombol + di sebelah pilihan kategori saat mencatat transaksi.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cats.map((cat) {
                  return Chip(
                    backgroundColor: AppColors.cardSecondary,
                    avatar: Icon(
                      CategoryModel.getIconByKey(cat.iconKey),
                      size: 16,
                      color: cat.type == 'income'
                          ? AppColors.incomeGreen
                          : AppColors.primaryBlue,
                    ),
                    label: Text(
                      cat.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    onDeleted: () {
                      if (cat.id != null) {
                        _categoryController.deleteCategory(cat.id!);
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNetWorthCard(bool isHidden) {
    return StreamBuilder<List<TransactionModel>>(
      stream: _trxController.getTransactionsStream(),
      builder: (context, trxSnap) {
        final transactions = trxSnap.data ?? [];
        double walletTotal = 0;
        for (final t in transactions) {
          if (t.type == 'income') walletTotal += t.amount;
          if (t.type == 'expense') walletTotal -= t.amount;
        }

        return StreamBuilder<List<SavingGoalModel>>(
          stream: _goalController.getGoalsStream(),
          builder: (context, goalSnap) {
            final savingsTotal = (goalSnap.data ?? [])
                .fold<double>(0, (acc, g) => acc + g.currentAmount);

            return StreamBuilder<List<DebtModel>>(
              stream: _debtController.getDebtsStream(),
              builder: (context, debtSnap) {
                double receivableTotal = 0;
                double payableTotal = 0;
                for (final d in debtSnap.data ?? []) {
                  if (!d.isPaid) {
                    if (d.type == 'receivable') {
                      receivableTotal += d.amount;
                    } else {
                      payableTotal += d.amount;
                    }
                  }
                }

                final netWorth =
                    walletTotal + savingsTotal + receivableTotal - payableTotal;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Kekayaan Bersih',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        PrivacyService.formatCurrency(
                          netWorth,
                          _currencyFormat,
                          isHidden,
                        ),
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _netWorthRow(
                        'Total Saldo Dompet',
                        PrivacyService.formatCurrency(
                          walletTotal,
                          _currencyFormat,
                          isHidden,
                        ),
                        AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      _netWorthRow(
                        'Total Dana Tabungan',
                        PrivacyService.formatCurrency(
                          savingsTotal,
                          _currencyFormat,
                          isHidden,
                        ),
                        AppColors.purpleAccent,
                      ),
                      const SizedBox(height: 8),
                      _netWorthRow(
                        'Piutang Aktif (+)',
                        PrivacyService.formatCurrency(
                          receivableTotal,
                          _currencyFormat,
                          isHidden,
                        ),
                        AppColors.incomeGreen,
                      ),
                      const SizedBox(height: 8),
                      _netWorthRow(
                        'Hutang Aktif (-)',
                        PrivacyService.formatCurrency(
                          payableTotal,
                          _currencyFormat,
                          isHidden,
                        ),
                        AppColors.expenseRed,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _netWorthRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser;
    final displayName = user?.displayName ?? 'Pengguna Money Tracker';

    return ValueListenableBuilder<bool>(
      valueListenable: PrivacyService.isHiddenNotifier,
      builder: (context, isHidden, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profil Akun')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryBlue,
                        child: Icon(
                          Icons.person,
                          size: 38,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: AppColors.accentBlue,
                            ),
                            onPressed: () => _showEditNameDialog(displayName),
                          ),
                        ],
                      ),
                      Text(
                        user?.email ?? '-',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildNetWorthCard(isHidden),
                const SizedBox(height: 16),
                _buildSecurityAndPreferencesCard(isHidden),
                const SizedBox(height: 16),
                _buildCustomCategoriesCard(),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expenseRed,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async => await _authController.logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Keluar (Logout)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}