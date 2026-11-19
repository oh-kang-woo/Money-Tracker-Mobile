import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/firebase_collections.dart';
import '../../models/bill_model.dart';
import '../../models/debt_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _dailyReminderKey = 'daily_reminder_enabled';
  static const String _lastDueAlertKey = 'last_due_alert_date';
  static const int _dailyNotificationId = 100;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'money_tracker_channel',
    'Pengingat Keuangan',
    channelDescription:
        'Notifikasi pengingat catatan harian dan jatuh tempo tagihan',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const NotificationDetails _notificationDetails =
      NotificationDetails(android: _androidDetails);

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings: initSettings);
  }

  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImpl?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyReminderKey) ?? false;
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderKey, enabled);

    if (enabled) {
      await requestPermission();
      await _plugin.periodicallyShow(
        id: _dailyNotificationId,
        title: 'Waktunya Catat Keuangan!',
        body: 'Jangan lupa catat pemasukan dan pengeluaranmu hari ini.',
        repeatInterval: RepeatInterval.daily,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      await _plugin.cancel(id: _dailyNotificationId);
    }
  }

  Future<void> showInstantNotification({
    int id = 999,
    required String title,
    required String body,
  }) async {
    await requestPermission();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails,
    );
  }

  // Cek otomatis tagihan rutin & hutang yang jatuh tempo hari ini atau besok
  Future<void> checkUpcomingDueReminders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_lastDueAlertKey) == todayKey) return;

    final tomorrow = now.add(const Duration(days: 1));
    final List<String> alerts = [];

    // 1. Cek Tagihan Rutin yang belum dibayar bulan ini
    final billSnap = await FirebaseFirestore.instance
        .collection(FirebaseCollections.bills)
        .where('userId', isEqualTo: uid)
        .get();

    for (final doc in billSnap.docs) {
      final bill = BillModel.fromFirestore(doc);
      if (!bill.isPaidForMonth(now)) {
        if (bill.dueDay == now.day) {
          alerts.add('Tagihan "${bill.title}" jatuh tempo HARI INI');
        } else if (bill.dueDay == tomorrow.day) {
          alerts.add('Tagihan "${bill.title}" jatuh tempo BESOK');
        }
      }
    }

    // 2. Cek Hutang / Piutang aktif
    final debtSnap = await FirebaseFirestore.instance
        .collection(FirebaseCollections.debts)
        .where('userId', isEqualTo: uid)
        .get();

    for (final doc in debtSnap.docs) {
      final debt = DebtModel.fromFirestore(doc);
      if (!debt.isPaid) {
        final isToday = debt.dueDate.year == now.year &&
            debt.dueDate.month == now.month &&
            debt.dueDate.day == now.day;
        final isTomorrow = debt.dueDate.year == tomorrow.year &&
            debt.dueDate.month == tomorrow.month &&
            debt.dueDate.day == tomorrow.day;

        final label = debt.type == 'payable' ? 'Hutang ke' : 'Piutang dari';
        if (isToday) {
          alerts.add('$label ${debt.personName} jatuh tempo HARI INI');
        } else if (isTomorrow) {
          alerts.add('$label ${debt.personName} jatuh tempo BESOK');
        }
      }
    }

    if (alerts.isNotEmpty) {
      await prefs.setString(_lastDueAlertKey, todayKey);
      await showInstantNotification(
        id: 201,
        title: 'Pengingat Jatuh Tempo (${alerts.length})',
        body: alerts.join(' • '),
      );
    }
  }
}