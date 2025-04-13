class GeneDto {
  int id;
  String name;

  GeneDto({
    required this.id,
    required this.name,
  });

  factory GeneDto.fromJson(Map<String, dynamic> json) {
    return GeneDto(
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
  factory GeneDto.empty() {
    return GeneDto(id: 0, name: '');
  }

  // // Переопределяем оператор сравнения
  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is GeneDto && runtimeType == other.runtimeType && id == other.id;
  //
  // // И хеш-код (для корректной работы в Set, Map и т.п.)
  // @override
  // int get hashCode => id.hashCode;
}
