class ColorDto {
  int id;
  String name;
  String hex;

  ColorDto({
    required this.id,
    required this.name,
    required this.hex,
  });

  factory ColorDto.fromJson(Map<String, dynamic> json) {
    return ColorDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      hex: json['hex'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hex': hex,
    };
  }
  factory ColorDto.empty() {
    return ColorDto(id: 0, name: '', hex: '');
  }
  // Переопределяем оператор сравнения
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorDto && runtimeType == other.runtimeType && id == other.id;

  // И хеш-код (для корректной работы в Set, Map и т.п.)
  @override
  int get hashCode => id.hashCode;
}
