import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isPositive;
  final IconData icon;
  final Color? customColor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isPositive,
    required this.icon,
    this.customColor,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        customColor ?? (isPositive ? AppColors.incomeGreen : AppColors.expenseRed);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}