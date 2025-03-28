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
}
