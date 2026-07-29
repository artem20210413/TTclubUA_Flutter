import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 🔥 Імпортуємо для форматування дати
import 'package:tt_club_ua/Storage/UserStorage.dart'; //[cite: 3]
import 'package:tt_club_ua/config/default.dart'; //[cite: 3]
import '../../../../Storage/Cache/AccentColorCache.dart'; //[cite: 3]
import '../../../../api/routs/Dto/Costs/CostsDto.dart'; //[cite: 3]
import '../../../../api/routs/Dto/Finance/SeasonStatisticsDto.dart';
import '../../../../api/routs/costs.dart'; //[cite: 3]

// Твої фірмові компоненти
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/statistic/TTStatisticGauge.dart';
import 'CostDetailScreen.dart';
import 'CostFormScreen.dart';

class CostsListScreen extends StatefulWidget {
  @override
  _CostsListScreenState createState() => _CostsListScreenState();
}

class _CostsListScreenState extends State<CostsListScreen> {
  // Рік, з якого клуб веде облік сезонів (сезон починається 1 вересня).
  static const int _clubFoundingYear = 2021;

  // Доступні для вибору сезони (роки початку сезону), найновіший — перший.
  List<int> _availableYears = [];

  // Обраний сезон + його витрати (пагіновані per FR-004/FR-005)
  SeasonStatisticsDto? _selectedSeason;
  final List<CostsDto> _costs = [];
  int _costsPage = 1;
  bool _hasMoreCosts = true;
  bool _isLoadingMoreCosts = false;
  bool _costsPageError = false;

  bool _isLoadingInitial = true;
  bool _initialLoadError = false;

  bool _isAdmin = false;

  final ScrollController _scrollController = ScrollController();
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadInitial();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreCosts();
      }
    });
  }

  // Метод перевірки прав адміністратора
  Future<void> _checkAdminStatus() async {
    final isAdmin = await UserStorage.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  // Форматування дати у формат "15 липня 2026"
  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return '';
    try {
      DateTime dateTime;
      if (dateInput is String) {
        dateTime = DateTime.parse(dateInput);
      } else if (dateInput is DateTime) {
        dateTime = dateInput;
      } else {
        return '';
      }
      return DateFormat('d MMMM yyyy', 'uk_UA').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  String _formatAmount(double value) {
    return NumberFormat.decimalPattern('uk_UA').format(value);
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingInitial = true;
      _initialLoadError = false;
    });

    final token = await UserStorage.getToken();
    final res = await FINANCE_STATISTICS_SEASONS(token, page: 1);

    if (res.statusCode == 200) {
      try {
        final body = jsonDecode(res.body)['data'];
        final season = SeasonStatisticsDto.fromJson(body);

        setState(() {
          // Усі сезони від заснування клубу до поточного, найновіший — перший.
          _availableYears = List.generate(
              season.year - _clubFoundingYear + 1, (i) => season.year - i);
          _isLoadingInitial = false;
        });

        _applySeason(season);
      } catch (_) {
        setState(() {
          _isLoadingInitial = false;
          _initialLoadError = true;
        });
      }
    } else {
      setState(() {
        _isLoadingInitial = false;
        _initialLoadError = true;
      });
    }
  }

  void _applySeason(SeasonStatisticsDto season) {
    setState(() {
      _selectedSeason = season;
      _costs
        ..clear()
        ..addAll(season.costs.data);
      _costsPage = season.costs.currentPage;
      _hasMoreCosts = season.costs.hasMore;
      _costsPageError = false;
    });
  }

  Future<void> _fetchSeason(int year) async {
    setState(() {
      _isLoadingInitial = true;
      _initialLoadError = false;
    });

    final token = await UserStorage.getToken();
    final res = await FINANCE_STATISTICS_SEASONS(token, year: year, page: 1);

    if (res.statusCode == 200) {
      try {
        final body = jsonDecode(res.body)['data'];
        final season = SeasonStatisticsDto.fromJson(body);
        setState(() => _isLoadingInitial = false);
        _applySeason(season);
      } catch (_) {
        setState(() {
          _isLoadingInitial = false;
          _initialLoadError = true;
        });
      }
    } else {
      setState(() {
        _isLoadingInitial = false;
        _initialLoadError = true;
      });
    }
  }

  Future<void> _selectYear(int year) async {
    if (_selectedSeason != null && _selectedSeason!.year == year) return;
    await _fetchSeason(year);
  }

  Future<void> _reloadSelectedSeason() async {
    if (_selectedSeason == null) return;
    await _fetchSeason(_selectedSeason!.year);
  }

  Future<void> _loadMoreCosts() async {
    if (_isLoadingMoreCosts || !_hasMoreCosts || _selectedSeason == null) {
      return;
    }

    setState(() {
      _isLoadingMoreCosts = true;
      _costsPageError = false;
    });

    final token = await UserStorage.getToken();
    final season = _selectedSeason!;
    final res = await FINANCE_STATISTICS_SEASONS(
      token,
      year: season.year,
      page: _costsPage + 1,
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body)['data'];
      final nextSeason = SeasonStatisticsDto.fromJson(body);

      setState(() {
        _costs.addAll(nextSeason.costs.data);
        _costsPage = nextSeason.costs.currentPage;
        _hasMoreCosts = nextSeason.costs.hasMore;
        _isLoadingMoreCosts = false;
      });
    } else {
      setState(() {
        _isLoadingMoreCosts = false;
        _costsPageError = true;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (_selectedSeason == null) {
      await _loadInitial();
      return;
    }
    await _reloadSelectedSeason();
  }

  void _openEdit(CostsDto dto) async {
    if (!_isAdmin) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CostFormScreen(cost: dto)),
    );

    if (result != null) {
      await _reloadSelectedSeason();
    }
  }

  void _openCreate() async {
    if (!_isAdmin) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CostFormScreen()),
    );

    if (result != null) {
      await _reloadSelectedSeason();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Витрати клубу',
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
              accentColor: accentColor,
              onPressed: _openCreate,
            )
          : null,
      body: _isLoadingInitial && _selectedSeason == null
          ? const TTLoading()
          : _initialLoadError && _selectedSeason == null
              ? _buildInitialError()
              : RefreshIndicator(
                  color: accentColor,
                  backgroundColor: TTColors.background,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 100),
                    itemCount: 1 +
                        (_costs.isEmpty ? 1 : _costs.length) +
                        ((_isLoadingMoreCosts || _costsPageError) ? 1 : 0),
                    itemBuilder: (context, index) {
                      // 1. Заголовок: вибір сезону + статистика
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildYearSelector(),
                            if (_selectedSeason != null)
                              _buildSeasonSummary(_selectedSeason!),
                          ],
                        );
                      }

                      final costIndex = index - 1;

                      // 2. Порожній стан
                      if (_costs.isEmpty) {
                        return _buildEmptyState();
                      }

                      // 3. Хвостовий елемент — лоадер/ретрай пагінації
                      if (costIndex == _costs.length) {
                        return _costsPageError
                            ? _buildInlineRetry()
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                      }

                      // 4. Картки витрат
                      final cost = _costs[costIndex];
                      return _buildCostCard(cost);
                    },
                  ),
                ),
    );
  }

  Widget _buildInitialError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Не вдалося завантажити дані',
              style: TTTextStyle.title18.copyWith(color: TTColors.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitial,
              child: const Text('Спробувати ще раз'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineRetry() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: TextButton(
          onPressed: _loadMoreCosts,
          child: const Text('Спробувати ще раз'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'Витрат ще немає',
          style: TTTextStyle.subtitle.copyWith(color: TTColors.text_secondary),
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    if (_selectedSeason == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TTNeumorphicBox(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedSeason!.year,
            isExpanded: true,
            dropdownColor: TTColors.card,
            icon: Icon(Icons.expand_more, color: accentColor),
            style: TTTextStyle.subtitle.copyWith(
              fontSize: 14,
              color: TTColors.text,
              fontWeight: FontWeight.w600,
            ),
            items: _availableYears
                .map(
                  (year) => DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      year == _availableYears.first
                          ? 'Поточний сезон ($year–${year + 1})'
                          : 'Сезон $year–${year + 1}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (year) {
              if (year != null) _selectYear(year);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonSummary(SeasonStatisticsDto season) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          TTStatisticGauge(
            value: season.collectedTotal,
            total: season.spentTotal,
            unit: "₴",
            valueLabel: 'Зібрано: ',
            totalLabel: '  •  з витрачених ',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceLabel(
                  'Баланс на початок', season.openingBalance),
              _buildBalanceLabel(
                  'Баланс на кінець', season.closingBalance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceLabel(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              TTTextStyle.subtitle.copyWith(fontSize: 11, color: TTColors.text_secondary),
        ),
        Text(
          '${_formatAmount(value)} ₴',
          style: TTTextStyle.subtitle.copyWith(
              fontSize: 14, color: TTColors.text, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _openDetails(CostsDto cost) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CostDetailScreen(cost: cost)),
    );
  }

  Widget _buildCostCard(CostsDto cost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TTNeumorphicBox(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => _openDetails(cost),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8, right: 16, top: 16, bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cost.amount} ₴',
                              style: TTTextStyle.title.copyWith(
                                fontSize: 18,
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Дата фіксації витрати (без інформації про власника — per FR-002)
                            Text(
                              _formatDate(cost.createdAt),
                              style: TTTextStyle.subtitle.copyWith(
                                fontSize: 11,
                                color: TTColors.text_secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cost.description.isNotEmpty
                              ? cost.description
                              : 'Без опису',
                          style: TTTextStyle.subtitle.copyWith(
                            fontSize: 14,
                            color: TTColors.text,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (cost.description.length > 90) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Детальніше',
                                style: TTTextStyle.subtitle.copyWith(
                                  fontSize: 12,
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  size: 16, color: accentColor),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 🔥 Кнопка редагування доступна ТІЛЬКИ для адмінів
                  if (_isAdmin) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: TTColors.text_secondary,
                        size: 26,
                      ),
                      onPressed: () => _openEdit(cost),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
