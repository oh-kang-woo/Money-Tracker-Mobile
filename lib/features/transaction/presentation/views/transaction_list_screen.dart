import 'package:flutter/material.dart';
import 'package:utsproject/app/config/app_colors.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  int _selectedTimeframe = 1; // 0: Week, 1: Month, 2: Year, 3: All
  int _navIndex = 0;
  String _selectedAccount = 'Main Account';
  int? _hoveredIndex;

  final List<String> _timeframes = ['Week', 'Month', 'Year', 'All'];

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Shopping',
      'spent': '\$800.50',
      'total': '\$1000.00',
      'progress': 0.80,
      'color': AppColors.accentBlue,
      'icon': Icons.shopping_bag_rounded,
      'sub': '2 Transactions'
    },
    {
      'title': 'Food & Drink',
      'spent': '\$300.49',
      'total': '\$500.00',
      'progress': 0.60,
      'color': AppColors.expenseRed,
      'icon': Icons.fastfood_rounded,
      'sub': '3 Transactions'
    },
    {
      'title': 'Trips',
      'spent': '\$190.90',
      'total': '\$270.00',
      'progress': 0.70,
      'color': AppColors.purpleAccent,
      'icon': Icons.directions_boat_rounded,
      'sub': '1 Transaction'
    },
    {
      'title': 'Health & Beauty',
      'spent': '\$140.53',
      'total': '\$235.00',
      'progress': 0.59,
      'color': AppColors.incomeGreen,
      'icon': Icons.favorite_rounded,
      'sub': '4 Transactions'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopAppBar(),
                  const SizedBox(height: 18),
                  _buildBalanceBannerCard(),
                  const SizedBox(height: 20),
                  _buildTimeframeSelector(),
                  const SizedBox(height: 20),
                  _buildInteractiveChartCard(),
                  const SizedBox(height: 20),
                  _buildCashFlowSummary(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category Summary',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(color: AppColors.accentBlue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return _buildInteractiveCategoryTile(index);
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavWithFAB(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showAccountBottomSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.accentBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  _selectedAccount,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        Row(
          children: [
            _buildCircleIconButton(Icons.search_rounded, () {}),
            const SizedBox(width: 10),
            _buildCircleIconButton(Icons.notifications_none_rounded, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceBannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Account balance',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'This month',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '10,157 \$',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.incomeGreen.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_upward_rounded, color: AppColors.incomeGreen, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '+\$2,775',
                      style: TextStyle(color: AppColors.incomeGreen, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Other Accounts: Credit Card', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Row(
                children: const [
                  Text('2000\$', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 10),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: List.generate(_timeframes.length, (index) {
          final isSelected = _selectedTimeframe == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeframe = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _timeframes[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInteractiveChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Feb 01 - 28, 2026', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('+\$975.50', style: TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: WaveChartPainter(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Feb 01', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Feb 03', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Feb 05', style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold, fontSize: 11)),
              Text('Feb 07', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('Feb 09', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowSummary() {
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
          const Text('Cash Flow', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  CircleAvatar(radius: 5, backgroundColor: AppColors.incomeGreen),
                  SizedBox(width: 8),
                  Text('Income', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              Text('+\$20,208.85', style: TextStyle(color: AppColors.incomeGreen, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  CircleAvatar(radius: 5, backgroundColor: AppColors.expenseRed),
                  SizedBox(width: 8),
                  Text('Expenses', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              Text('-\$10,372.02', style: TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCategoryTile(int index) {
    final item = _categories[index];
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isHovered ? AppColors.cardSecondary : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isHovered ? AppColors.accentBlue : AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(item['sub'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item['spent'] as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('from ${item['total']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: item['progress'] as double,
                  backgroundColor: AppColors.cardSecondary,
                  color: item['color'] as Color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  Widget _buildBottomNavWithFAB() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.account_balance_wallet_rounded, 0),
          _buildNavItem(Icons.history_rounded, 1),
          Transform.translate(
            offset: const Offset(0, -16),
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.primaryBlue,
              elevation: 8,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          ),
          _buildNavItem(Icons.bar_chart_rounded, 2),
          _buildNavItem(Icons.grid_view_rounded, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _navIndex == index;
    return IconButton(
      onPressed: () => setState(() => _navIndex = index),
      icon: Icon(
        icon,
        color: isSelected ? AppColors.accentBlue : AppColors.textMuted,
        size: 24,
      ),
    );
  }

  void _showAccountBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Account', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildAccountOption('Main Account', '\$10,157.00'),
              _buildAccountOption('Credit Card', '\$2,000.00'),
              _buildAccountOption('Savings Account', '\$4,500.00'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountOption(String title, String balance) {
    return ListTile(
      onTap: () {
        setState(() => _selectedAccount = title);
        Navigator.pop(context);
      },
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: Text(balance, style: const TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold)),
    );
  }
}

class WaveChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.accentBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.7, size.width, size.height * 0.3);

    canvas.drawPath(path, paintLine);

    final dotPaint = Paint()..color = AppColors.primaryBlue;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}