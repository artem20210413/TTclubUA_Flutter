class ModelDto {
  int id;
  String name;

  ModelDto({
    required this.id,
    required this.name,
  });

  factory ModelDto.fromJson(Map<String, dynamic> json) {
    return ModelDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
  factory ModelDto.empty() {
    return ModelDto(id: 0, name: '');
  }
  // Переопределяем оператор сравнения
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelDto && runtimeType == other.runtimeType && id == other.id;

  // И хеш-код (для корректной работы в Set, Map и т.п.)
  @override
  int get hashCode => id.hashCode;
}
