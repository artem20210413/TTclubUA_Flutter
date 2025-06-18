import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceItemCard extends StatelessWidget {
  final dynamic finance; // Лучше заменить на DTO, если есть

  const FinanceItemCard({super.key, required this.finance});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.savings_outlined, color: Colors.pink),
        title: Text(
          '${finance.amount} грн',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (finance.description != null && finance.description.isNotEmpty)
              Text(finance.description)
            else
              const Text('Без опису', style: TextStyle(color: Colors.grey)),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(finance.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
