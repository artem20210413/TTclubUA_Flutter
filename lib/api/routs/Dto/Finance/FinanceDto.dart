import 'package:intl/intl.dart';

class FinanceDto {
  int id;
  String amount;
  String description;
  DateTime createdAt;

  FinanceDto({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory FinanceDto.fromJson(Map<String, dynamic> json) {
    return FinanceDto(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'created_at': DateFormat('dd.MM.yyyy HH:mm').format(this.createdAt),
    };
  }
}
