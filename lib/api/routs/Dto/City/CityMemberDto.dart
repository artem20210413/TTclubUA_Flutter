import '../../../../Helpers/ImageUrl.dart';

const String _kDefaultAvatarFileName = 'default/profile_picture.webp';

class CityMemberDto {
  int id;
  String name;
  String? profileImage;
  List<String> roles;
  String? telegramNickname;
  String? instagramNickname;
  DateTime? updatedAt;

  CityMemberDto({
    required this.id,
    required this.name,
    this.profileImage,
    this.roles = const [],
    this.telegramNickname,
    this.instagramNickname,
    this.updatedAt,
  });

  /// True when the avatar is the backend's default placeholder (not a real photo).
  bool get hasDefaultAvatar =>
      profileImage == null ||
      profileImage!.isEmpty ||
      profileImage!.endsWith(_kDefaultAvatarFileName);

  factory CityMemberDto.fromJson(Map<String, dynamic> json) {
    return CityMemberDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profileImage: absolutizeImageUrl(_extractProfileImage(json)),
      roles: ((json['roles'] ?? []) as List)
          .map((role) => role is String ? role : (role?['name'] ?? '').toString())
          .where((role) => role.isNotEmpty)
          .toList()
          .cast<String>(),
      telegramNickname: json['telegram_nickname'] as String?,
      instagramNickname: json['instagram_nickname'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Tolerates a few common backend field-name variants for the member
  /// avatar (exact key confirmed against the live backend).
  static String? _extractProfileImage(Map<String, dynamic> json) {
    for (final key in [
      'profile_image',
      'avatar',
      'avatar_url',
      'photo',
      'photo_url',
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
      'profile_image': profileImage,
      'roles': roles,
      'telegram_nickname': telegramNickname,
      'instagram_nickname': instagramNickname,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
