import '../../../../Helpers/ImageUrl.dart';

class CityMapPointDto {
  int id;
  String name;
  double latitude;
  double longitude;
  int usersCount;
  String? avatarUrl;

  CityMapPointDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.usersCount,
    this.avatarUrl,
  });

  /// Single member with a photo -> circular avatar marker.
  bool get showsAvatar => usersCount == 1 && avatarUrl != null;

  factory CityMapPointDto.fromJson(Map<String, dynamic> json) {
    return CityMapPointDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      usersCount: (json['users_count'] as num?)?.toInt() ?? 0,
      avatarUrl: absolutizeImageUrl(_extractAvatarUrl(json)),
    );
  }

  /// Tolerates a few common backend field-name variants for the marker's
  /// representative avatar (exact key confirmed against the live backend).
  static String? _extractAvatarUrl(Map<String, dynamic> json) {
    for (final key in [
      'avatar',
      'avatar_url',
      'photo',
      'photo_url',
      'profile_image',
      'image',
    ]) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
      if (value is Map<String, dynamic>) {
        final nested = value['url'] ?? value['path'];
        if (nested is String && nested.isNotEmpty) return nested;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'users_count': usersCount,
      'avatar': avatarUrl,
    };
  }
}
