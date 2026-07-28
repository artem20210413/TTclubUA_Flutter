import '../api/routs.dart';

/// Some backend responses return storage-relative paths instead of full URLs;
/// this makes both work the same way for network image widgets.
String? absolutizeImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '$URL_HOST/${url.startsWith('/') ? url.substring(1) : url}';
}
