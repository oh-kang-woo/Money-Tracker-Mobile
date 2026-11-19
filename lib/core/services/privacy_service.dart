import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyService {
  static const String _privacyKey = 'hide_balance_mode';
  static final ValueNotifier<bool> isHiddenNotifier = ValueNotifier<bool>(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isHiddenNotifier.value = prefs.getBool(_privacyKey) ?? false;
  }

  static Future<void> togglePrivacy() async {
    final nextValue = !isHiddenNotifier.value;
    isHiddenNotifier.value = nextValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyKey, nextValue);
  }

  static Future<void> setPrivacy(bool hide) async {
    isHiddenNotifier.value = hide;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyKey, hide);
  }

  static String formatCurrency(
    double amount,
    NumberFormat formatter,
    bool isHidden, {
    String prefix = '',
  }) {
    if (isHidden) {
      return '${prefix}Rp ••••••';
    }
    return '$prefix${formatter.format(amount)}';
  }
}