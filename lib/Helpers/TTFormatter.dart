class TTFormatter {
  /// Просто выводит формат: 2025-12-24
  static String formatDate(DateTime? date) {
    if (date == null) return '';

    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return "$year-$month-$day";
  }

  /// Если нужен привычный формат для карточек: 24.12.2025
  static String formatDateUI(DateTime? date) {
    if (date == null) return '';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return "$day.$month.$year";
  }
}