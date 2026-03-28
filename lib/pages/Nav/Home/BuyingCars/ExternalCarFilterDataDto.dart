class ExternalCarFilterDataDto {
  final List<int> years;
  final List<String> models;
  final List<String> subCategories;
  final List<String> colors;

  // Межі цін
  final int minPrice;
  final int maxPrice;

  // Межі років (вираховуємо зі списку років)
  final int minYear;
  final int maxYear;

  ExternalCarFilterDataDto({
    required this.years,
    required this.models,
    required this.subCategories,
    required this.colors,
    required this.minPrice,
    required this.maxPrice,
    required this.minYear,
    required this.maxYear,
  });

  factory ExternalCarFilterDataDto.fromJson(Map<String, dynamic> json) {
    final List<int> yearList = List<int>.from(json['years'] ?? []);

    // Знаходимо мін/макс рік зі списку, якщо він не порожній
    int currentMinYear = yearList.isNotEmpty ? yearList.reduce((a, b) => a < b ? a : b) : 1990;
    int currentMaxYear = yearList.isNotEmpty ? yearList.reduce((a, b) => a > b ? a : b) : DateTime.now().year;

    return ExternalCarFilterDataDto(
      years: yearList,
      models: List<String>.from(json['models'] ?? []),
      subCategories: List<String>.from(json['sub_categories'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      minPrice: json['price_bounds']?['min'] ?? 0,
      maxPrice: json['price_bounds']?['max'] ?? 100000,
      minYear: currentMinYear,
      maxYear: currentMaxYear,
    );
  }

  // Порожній стан (щоб не було null-errors до завантаження)
  factory ExternalCarFilterDataDto.empty() {
    return ExternalCarFilterDataDto(
      years: [],
      models: [],
      subCategories: [],
      colors: [],
      minPrice: 0,
      maxPrice: 100000,
      minYear: 1990,
      maxYear: 2026,
    );
  }
}