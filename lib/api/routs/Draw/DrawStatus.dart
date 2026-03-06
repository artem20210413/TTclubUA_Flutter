import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../../Storage/Cache/AccentColorCache.dart';

enum DrawStatus {
  planned('planned', 'Заплановано', Colors.lightBlue),
  active('active', 'Активний', Colors.green),
  finished('finished', 'Завершено', TTColors.text_secondary),
  cancelled('cancelled', 'Скасовано', TTColors.text_secondary);

  // Поля енаму
  final String value;
  final String label;
  final Color color;
  // Конструктор
  const DrawStatus(this.value, this.label, this.color);

  /// Метод для отримання енаму з рядка (корисно для API)
  static DrawStatus fromString(String status) {
    return DrawStatus.values.firstWhere(
          (e) => e.value == status,
      orElse: () => DrawStatus.planned,
    );
  }
}
// Color getStatusColor(DrawStatus status) {
//   switch (status) {
//     case DrawStatus.active: return Colors.green;
//     case DrawStatus.planned: return Colors.blue;
//     case DrawStatus.cancelled: return Colors.red;
//     case DrawStatus.finished: return Colors.grey;
//   }
// }