import 'package:bazzar_hub_app/presentation/services/models/wallet/wallet_transactions_model.dart';
import 'package:flutter/material.dart';

import '../../../app/core/utils/utils.dart';


class TransactionItemWidget extends StatelessWidget {

  final WalletTransactionsModel transaction;

  const TransactionItemWidget({super.key, required this.transaction});

  bool get _isCompleted => (transaction.status).toLowerCase() == 'completed';
  bool get _isPending   => (transaction.status).toLowerCase() == 'pending';
  bool get _isRejected  => (transaction.status).toLowerCase() == 'rejected';

  Color get statusColor {
    if (_isCompleted) return Colors.green;
    if (_isPending)   return Colors.orange;
    if (_isRejected)  return Colors.red;
    return Colors.grey;
  }

  IconData get statusIcon {
    if (_isCompleted) return Icons.check_circle_rounded;
    if (_isPending)   return Icons.hourglass_bottom_rounded;
    if (_isRejected)  return Icons.cancel_rounded;
    return Icons.info_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor
          ),
          child: Center(
            child: Icon(statusIcon, color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                (transaction.title).isNotEmpty ? transaction.title : 'Wallet Transaction',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              transaction.coins.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              Utils.formatDateWithDay(transaction.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: statusColor.withOpacity(0.12),
                    border: Border.all(
                      color: statusColor,
                    ),
                  ),
                  child: Text(
                    (transaction.status).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}