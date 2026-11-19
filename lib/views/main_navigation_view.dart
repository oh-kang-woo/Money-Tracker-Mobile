import 'package:flutter/material.dart';
import '../app/config/app_colors.dart';
import '../core/services/app_lock_service.dart';
import '../core/services/notification_service.dart';
import '../features/analytics/presentation/views/analytics_screen.dart';
import '../features/auth/presentation/views/pin_lock_screen.dart';
import '../features/budget/presentation/views/budget_screen.dart';
import '../features/debt/presentation/views/debt_screen.dart';
import '../features/profile/presentation/views/profile_screen.dart';
import 'home_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView>
    with WidgetsBindingObserver {
  final AppLockService _lockService = AppLockService();
  int _currentIndex = 0;
  bool _isCheckingLock = true;
  bool _isLocked = false;

  final List<Widget> _pages = const [
    HomeView(),
    AnalyticsScreen(),
    BudgetScreen(),
    DebtScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
    NotificationService().checkUpcomingDueReminders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockOnBackground();
    }
  }

  Future<void> _checkInitialLock() async {
    final hasPin = await _lockService.hasPin();
    if (mounted) {
      setState(() {
        _isLocked = hasPin;
        _isCheckingLock = false;
      });
    }
  }

  Future<void> _lockOnBackground() async {
    final hasPin = await _lockService.hasPin();
    if (hasPin && mounted) {
      setState(() => _isLocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLock) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLocked) {
      return PinLockScreen(
        onUnlocked: () => setState(() => _isLocked = false),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.cardBackground,
        indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.25),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primaryBlue),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart, color: AppColors.primaryBlue),
            label: 'Statistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings, color: AppColors.primaryBlue),
            label: 'Rencana',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake, color: AppColors.primaryBlue),
            label: 'Hutang',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primaryBlue),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}