import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../core/services/app_lock_service.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSetupMode;
  final VoidCallback? onUnlocked;

  const PinLockScreen({
    super.key,
    this.isSetupMode = false,
    this.onUnlocked,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final AppLockService _lockService = AppLockService();
  String _enteredPin = '';
  String? _firstSetupPin;
  String _errorMessage = '';
  bool _showBiometricBtn = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isSetupMode) {
      _initBiometric();
    }
  }

  Future<void> _initBiometric() async {
    final bioEnabled = await _lockService.isBiometricEnabled();
    final canBio = await _lockService.canUseBiometric();
    if (bioEnabled && canBio && mounted) {
      setState(() => _showBiometricBtn = true);
      _triggerBiometric();
    }
  }

  Future<void> _triggerBiometric() async {
    final success = await _lockService.authenticateWithBiometric();
    if (success && mounted) {
      widget.onUnlocked?.call();
    }
  }

  Future<void> _onDigitPressed(String digit) async {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
      _errorMessage = '';
    });

    if (_enteredPin.length == 4) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (widget.isSetupMode) {
        if (_firstSetupPin == null) {
          setState(() {
            _firstSetupPin = _enteredPin;
            _enteredPin = '';
          });
        } else if (_firstSetupPin == _enteredPin) {
          await _lockService.setPin(_enteredPin);
          if (mounted) Navigator.pop(context, true);
        } else {
          setState(() {
            _firstSetupPin = null;
            _enteredPin = '';
            _errorMessage = 'PIN tidak cocok. Ulangi dari awal.';
          });
        }
      } else {
        final savedPin = await _lockService.getPin();
        if (_enteredPin == savedPin) {
          widget.onUnlocked?.call();
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = 'PIN salah, silakan coba lagi.';
          });
        }
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Masukkan PIN';
    String subtitle = 'Buka kunci untuk mengakses data keuanganmu';

    if (widget.isSetupMode) {
      title = _firstSetupPin == null ? 'Buat PIN 4-Digit' : 'Konfirmasi PIN';
      subtitle = _firstSetupPin == null
          ? 'Masukkan 4 angka PIN keamanan baru'
          : 'Masukkan ulang 4 angka PIN yang sama';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isSetupMode
          ? AppBar(backgroundColor: Colors.transparent)
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? AppColors.primaryBlue
                          : AppColors.cardSecondary,
                      border: Border.all(
                        color: filled
                            ? AppColors.primaryBlue
                            : AppColors.cardBorder,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 20,
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: AppColors.expenseRed,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['bio', '0', 'del'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key == 'bio') {
                return SizedBox(
                  width: 72,
                  height: 72,
                  child: _showBiometricBtn
                      ? IconButton(
                          icon: const Icon(
                            Icons.fingerprint,
                            size: 34,
                            color: AppColors.neonCyan,
                          ),
                          onPressed: _triggerBiometric,
                        )
                      : const SizedBox.shrink(),
                );
              }
              if (key == 'del') {
                return SizedBox(
                  width: 72,
                  height: 72,
                  child: IconButton(
                    icon: const Icon(
                      Icons.backspace_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _onBackspace,
                  ),
                );
              }
              return InkWell(
                onTap: () => _onDigitPressed(key),
                borderRadius: BorderRadius.circular(36),
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    key,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}