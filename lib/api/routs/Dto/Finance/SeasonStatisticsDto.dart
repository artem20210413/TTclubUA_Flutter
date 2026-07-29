import '../Costs/CostsDto.dart';

class PaginatedCosts {
  int currentPage;
  int lastPage;
  String? nextPageUrl;
  int perPage;
  int total;
  List<CostsDto> data;

  PaginatedCosts({
    required this.currentPage,
    required this.lastPage,
    required this.nextPageUrl,
    required this.perPage,
    required this.total,
    required this.data,
  });

  bool get hasMore => nextPageUrl != null && currentPage < lastPage;

  factory PaginatedCosts.fromJson(Map<String, dynamic> json) {
    return PaginatedCosts(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      nextPageUrl: json['next_page_url'],
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => CostsDto.fromJson(e))
          .toList(),
    );
  }
}

class SeasonStatisticsDto {
  DateTime seasonStart;
  DateTime? seasonEnd;
  double spentTotal;
  double collectedTotal;
  double openingBalance;
  double closingBalance;
  PaginatedCosts costs;

  SeasonStatisticsDto({
    required this.seasonStart,
    required this.seasonEnd,
    required this.spentTotal,
    required this.collectedTotal,
    required this.openingBalance,
    required this.closingBalance,
    required this.costs,
  });

  bool get isCurrent => seasonEnd == null;

  // Сезон стартує 1 вересня `year`-го року — саме це значення приймає
  // query-параметр `year` ендпоінту GET /api/finance/statistics/seasons.
  int get year => seasonStart.year;

  factory SeasonStatisticsDto.fromJson(Map<String, dynamic> json) {
    return SeasonStatisticsDto(
      seasonStart: DateTime.parse(json['season_start']),
      seasonEnd:
          json['season_end'] != null ? DateTime.parse(json['season_end']) : null,
      spentTotal: double.tryParse(json['spent_total']?.toString() ?? '') ?? 0,
      collectedTotal:
          double.tryParse(json['collected_total']?.toString() ?? '') ?? 0,
      openingBalance:
          double.tryParse(json['opening_balance']?.toString() ?? '') ?? 0,
      closingBalance:
          double.tryParse(json['closing_balance']?.toString() ?? '') ?? 0,
      costs: PaginatedCosts.fromJson(json['costs'] ?? {}),
    );
  }
}
