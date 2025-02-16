class CityDTO {
  int? id;
  String? name;
  String? country;
  double? latitude;
  double? longitude;

  CityDTO({
    this.id,
    this.name,
    this.country,
    this.latitude,
    this.longitude,
  });

  /// Фабричный метод для создания объекта из JSON
  factory CityDTO.fromJson(Map<String, dynamic> json) {
    return CityDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      country: json['country'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  /// Метод для конвертации объекта в JSON
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
