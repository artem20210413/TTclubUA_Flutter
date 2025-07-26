import 'package:intl/intl.dart';

import '../User/UserSmallDto.dart';

class CostsDto {
  int id;
  String amount;
  String description;
  UserSmallDto owner;
  DateTime createdAt;

  CostsDto({
    required this.id,
    required this.amount,
    required this.description,
    required this.owner,
    required this.createdAt,
  });

  factory CostsDto.fromJson(Map<String, dynamic> json) {
    return CostsDto(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? '',
      description: json['description'] ?? '',
      owner:  UserSmallDto.fromJson(json['owner']) ,
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
