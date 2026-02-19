enum DrawStatus {
  planned('planned'),
  active('active'),
  finished('finished'),
  cancelled('cancelled');

  // Поле для зберігання рядкового значення
  final String value;

  // Конструктор
  const DrawStatus(this.value);

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