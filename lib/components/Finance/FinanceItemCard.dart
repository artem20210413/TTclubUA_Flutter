import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/api/routs/Dto/Finance/FinanceDto.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/Storage/Cache/AccentColorCache.dart';

class FinanceItemCard extends StatelessWidget {
  final FinanceDto finance;

  const FinanceItemCard({super.key, required this.finance});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = AccentColorCache.accentColor;

    // Перевіряємо тип транзакції
    final Color statusColor = TTColors.text;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: TTColors.card.withOpacity(0.4), // Напівпрозорий фон картки
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TTColors.text_secondary.withOpacity(0.1),
          // Тонка ледь помітна лінія
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Мінімалістичний індикатор зліва (вертикальна лінія)
          Container(
            width: 3,
            height: 35,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 16),

          // Текстовий блок
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finance.description != null && finance.description!.isNotEmpty
                      ? finance.description!
                      : 'Внесок у клуб',
                  style: TTTextStyle.subtitle.copyWith(
                    color: TTColors.text,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMMM yyyy, HH:mm', 'uk_UA')
                      .format(finance.createdAt),
                  style: TTTextStyle.caption.copyWith(
                    color: TTColors.text_secondary.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Блок суми
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${finance.amount} ₴',
                style: TTTextStyle.title18.copyWith(
                  color: statusColor,
                  fontSize: 17,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class FinanceItemCard extends StatelessWidget {
//   final dynamic finance; // Лучше заменить на DTO, если есть
//
//   const FinanceItemCard({super.key, required this.finance});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: ListTile(
//         leading: const Icon(Icons.savings_outlined, color: Colors.pink),
//         title: Text(
//           '${finance.amount} грн',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (finance.description != null && finance.description.isNotEmpty)
//               Text(finance.description)
//             else
//               const Text('Без опису', style: TextStyle(color: Colors.grey)),
//             Text(
//               DateFormat('yyyy-MM-dd HH:mm').format(finance.createdAt),
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
