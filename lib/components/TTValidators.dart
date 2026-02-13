class TTValidators {
  /// Валідатор для обов'язкових полів (наприклад, Назва)
  static String? required(String? value,
      {String message = 'Обов’язкове поле'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Валідатор для посилань (необов'язковий)
  /// Якщо порожньо — пропускає. Якщо введено — перевіряє формат.
  static String? url(String? value) {
    print(value);
    if (value == null || value.trim().isEmpty) return null;

    final bool isUrl = Uri.tryParse(value)?.hasAbsolutePath ?? false;
    if (!isUrl || !value.contains('.')) {
      return 'Невірний формат посилання (напр. https://...)';
    }
    return null;
  }

  /// Валідатор для Instagram
  static String? instagram(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    if (!value.toLowerCase().contains('instagram.com')) {
      return 'Має містити instagram.com';
    }
    return null;
  }

  /// Валідатор для Google Maps (необов'язковий)
  static String? googleMaps(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final bool isUrl = Uri.tryParse(value)?.hasAbsolutePath ?? false;

    // Перевіряємо, чи це посилання на google maps або координати
    bool isGoogleMaps = value.contains('google.com/maps') ||
        value.contains('goo.gl/maps') ||
        value.contains('maps.app.goo.gl');

    if (!isUrl || !isGoogleMaps) {
      return 'Вставте коректне посилання з Google Maps';
    }
    return null;
  }

  /// Валідатор для пріоритету (тільки цифри)
  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    if (int.tryParse(value) == null) {
      return 'Введіть число';
    }
    return null;
  }
}
