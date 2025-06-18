import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsCard extends StatelessWidget {
  final Map<String, dynamic>? statistics;

  const StatisticsCard({super.key, required this.statistics});

  String _formatDouble(String? value) =>
      value == null ? '—' : double.parse(value).toStringAsFixed(2);

  String _formatDate(String? value) => value == null
      ? '—'
      : DateFormat('dd.MM.yyyy').format(DateTime.parse(value));

  @override
  Widget build(BuildContext context) {
    if (statistics == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Статистика',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Text('💰 Всього: ${statistics!['all_sum']} грн'),
            Text('📅 За рік: ${statistics!['last_year']} грн'),
            Text('🗓️ За місяць: ${statistics!['last_month']} грн'),
            const SizedBox(height: 10),
            Text('🔢 Кількість внесків: ${statistics!['total_payments_count']}'),
            Text('⚖️ Середній платіж: ${_formatDouble(statistics!['average_payment'])} грн'),
            Text('⬆️ Найбільший: ${_formatDouble(statistics!['largest_payment'])} грн'),
            Text('⬇️ Найменший: ${_formatDouble(statistics!['smallest_payment'])} грн'),
            const SizedBox(height: 10),
            Text('🕓 Останній платіж: ${_formatDate(statistics!['last_payment_date'])}'),
            Text('🕓 Перший платіж: ${_formatDate(statistics!['first_payment_date'])}'),
          ],
        ),
      ),
    );
  }
}
