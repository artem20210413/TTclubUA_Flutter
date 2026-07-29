import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../api/routs/Dto/Costs/CostsDto.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/layout/TTScaffold.dart';

class CostDetailScreen extends StatelessWidget {
  final CostsDto cost;

  const CostDetailScreen({super.key, required this.cost});

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm', 'uk_UA').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AccentColorCache.accentColor;

    return TTScaffold(
      title: 'Витрата',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: TTNeumorphicBox(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${cost.amount} ₴',
                  style: TTTextStyle.title.copyWith(
                    fontSize: 28,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: TTColors.text_secondary),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(cost.createdAt),
                      style: TTTextStyle.subtitle.copyWith(
                        fontSize: 13,
                        color: TTColors.text_secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Опис',
                  style: TTTextStyle.subtitle.copyWith(
                    fontSize: 12,
                    color: TTColors.text_secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  cost.description.isNotEmpty ? cost.description : 'Без опису',
                  style: TTTextStyle.subtitle.copyWith(
                    fontSize: 15,
                    color: TTColors.text,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
