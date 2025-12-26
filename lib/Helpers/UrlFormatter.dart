class UrlFormatter {
  /// Извлекает домен из ссылки (например, "google.com")
  static String getDomain(String? url) {
    if (url == null || url.trim().isEmpty) return '';

    try {
      String cleanUrl = url.trim();
      // Если нет протокола, Uri.parse может не выдать host, добавим временно
      if (!cleanUrl.startsWith('http')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);
      String host = uri.host.toLowerCase();

      // Убираем www.
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }

      return host;
    } catch (e) {
      return url; // Если ошибка, возвращаем как есть
    }
  }

  /// Извлекает никнейм из ссылки Instagram
  /// Поддерживает форматы:
  /// - https://instagram.com/username
  /// - instagram.com/username/
  /// - @username
  static String getInstagramHandle(String? url) {
    if (url == null || url.trim().isEmpty) return '';

    String clean = url.trim().toLowerCase();

    try {
      final uri = Uri.parse(clean.startsWith('http') ? clean : 'https://$clean');
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

      if (pathSegments.isNotEmpty) {
        return '${pathSegments.first}';
      }
    } catch (_) {}

    return clean; // Если не распарсили, вернем оригинал
  }
}