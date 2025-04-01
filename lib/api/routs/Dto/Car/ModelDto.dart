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
}
