import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockService {
  static const String _pinHashKey = 'app_lock_pin_hash';
  static const String _pinSaltKey = 'app_lock_pin_salt';
  static const String _legacyPinKey = 'app_lock_pin';
  static const String _bioKey = 'app_lock_biometric';
  static const String _failedAttemptsKey = 'app_lock_failed_attempts';
  static const String _lockoutUntilKey = 'app_lock_lockout_until';

  static const int maxFailedAttempts = 5;
  static const int lockoutSeconds = 30;

  final LocalAuthentication _localAuth = LocalAuthentication();

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_pinHashKey);
    if (hash != null && hash.isNotEmpty) return true;

    // Migrasi otomatis jika masih ada PIN plaintext versi lama
    final legacyPin = prefs.getString(_legacyPinKey);
    if (legacyPin != null && RegExp(r'^\d{4}$').hasMatch(legacyPin)) {
      await setPin(legacyPin);
      await prefs.remove(_legacyPinKey);
      return true;
    }
    return false;
  }

  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw ArgumentError('PIN harus terdiri dari tepat 4 angka.');
    }
    final prefs = await SharedPreferences.getInstance();
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    await prefs.setString(_pinSaltKey, salt);
    await prefs.setString(_pinHashKey, hash);
    await prefs.remove(_legacyPinKey);
    await resetFailedAttempts();
  }

  Future<bool> verifyPin(String inputPin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(inputPin)) return false;

    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_pinSaltKey);
    final savedHash = prefs.getString(_pinHashKey);

    if (salt == null || savedHash == null) return false;
    final isMatch = _hashPin(inputPin, salt) == savedHash;

    if (isMatch) {
      await resetFailedAttempts();
    }
    return isMatch;
  }

  Future<int> getRemainingLockoutSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntilMs = prefs.getInt(_lockoutUntilKey) ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (lockoutUntilMs <= nowMs) return 0;
    return ((lockoutUntilMs - nowMs) / 1000).ceil();
  }

  Future<int> recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_failedAttemptsKey, attempts);

    if (attempts >= maxFailedAttempts) {
      final untilMs =
          DateTime.now().millisecondsSinceEpoch + (lockoutSeconds * 1000);
      await prefs.setInt(_lockoutUntilKey, untilMs);
      await prefs.setInt(_failedAttemptsKey, 0);
      return lockoutSeconds;
    }
    return 0;
  }

  Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_lockoutUntilKey);
  }

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
    await prefs.remove(_pinSaltKey);
    await prefs.remove(_legacyPinKey);
    await prefs.setBool(_bioKey, false);
    await resetFailedAttempts();
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bioKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bioKey, enabled);
  }

  Future<bool> canUseBiometric() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Verifikasi sidik jari untuk membuka Money Tracker',
      );
    } catch (_) {
      return false;
    }
  }
}