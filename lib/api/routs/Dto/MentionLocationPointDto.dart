class MentionLocationPointDto {
  double latitude;
  double longitude;
  int count;

  MentionLocationPointDto({
    required this.latitude,
    required this.longitude,
    required this.count,
  });

  factory MentionLocationPointDto.fromJson(Map<String, dynamic> json) {
    return MentionLocationPointDto(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'count': count,
    };
  }
}
