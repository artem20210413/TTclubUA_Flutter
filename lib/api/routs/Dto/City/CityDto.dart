class CityDto {
  int id;
  String name;
  String country;
  double latitude;
  double longitude;

  CityDto({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory CityDto.fromJson(Map<String, dynamic> json) {
    return CityDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
