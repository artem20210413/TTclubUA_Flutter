import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 🔥 Імпортуємо для форматування дати
import 'package:tt_club_ua/Storage/UserStorage.dart'; //[cite: 3]
import 'package:tt_club_ua/components/generalModule.dart'; //[cite: 3]
import 'package:tt_club_ua/config/default.dart'; //[cite: 3]
import '../../../../Storage/Cache/AccentColorCache.dart'; //[cite: 3]
import '../../../../api/routs/Dto/Costs/CostsDto.dart'; //[cite: 3]
import '../../../../api/routs/costs.dart'; //[cite: 3]

// Твої фірмові компоненти
import '../../../../components/layout/TTScaffold.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/buttons/GlassFabFloatingButton.dart';
import '../../../../components/statistic/TTStatisticGauge.dart';

class CostsListScreen extends StatefulWidget {
  @override
  _CostsListScreenState createState() => _CostsListScreenState();
}

class _CostsListScreenState extends State<CostsListScreen> {
  final List<CostsDto> _costs = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isAdmin = false;
  double _statsSpent = 11010;
  double _statsTotal = 100000;

  final ScrollController _scrollController = ScrollController();
  Color accentColor = AccentColorCache.accentColor;

  @override
  void initState() {
    super.initState();
    // _checkAdminStatus();
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _loadMore();
        }
      }
    });
  }

  // Метод перевірки прав адміністратора
  Future<void> _checkAdminStatus() async {
    // Припускаємо, що у твоєму UserStorage є метод отримання ролі (наприклад, getRole)
    // Або адаптуй під свою перевірку (наприклад, UserStorage.isAdmin())
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

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final token = await UserStorage.getToken(); //[cite: 3]
    final res = await COSTS_LIST(token, page: _page); //[cite: 3]

    if (res.statusCode == 200) {
      //[cite: 3]
      final data = jsonDecode(res.body)['data'] as List; //[cite: 3]
      final newItems =
          data.map((e) => CostsDto.fromJson(e)).toList(); //[cite: 3]

      setState(() {
        _page++;
        _costs.addAll(newItems);
        _hasMore = newItems.length == 15;
      });
    }

    setState(() => _isLoading = false);
  }

  void _openEdit(CostsDto dto) {
    if (!_isAdmin) return;
    // Твій майбутній івент переходу на редагування
  }

  void _openCreate() {
    if (!_isAdmin) return;
    // Твій майбутній івент створення витрати
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Витрати клубу',
      // Показуємо кнопку додавання ТІЛЬКИ адміністраторам
      floatingActionButton: _isAdmin
          ? GlassFabFloatingButton(
        accentColor: accentColor,
        onPressed: _openCreate,
      )
          : null,
      body: _isLoading && _costs.isEmpty
          ? const TTLoading()
          : RefreshIndicator(
        color: accentColor,
        backgroundColor: TTColors.background,
        onRefresh: () async {
          setState(() {
            _costs.clear();
            _page = 1;
            _hasMore = true;
            // Тут також можеш скидати або перезапитувати статистику
          });
          await _loadMore();
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(
              left: 16, right: 16, top: 16, bottom: 100),
          itemCount: 1 + _costs.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            // 1. ПЕРШИЙ ЕЛЕМЕНТ (Індекс 0) — Наша статистика
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TTStatisticGauge(
                  value: _statsSpent, // 🔥 Беремо напряму зі стану
                  total: _statsTotal, // 🔥 Беремо напряму зі стану
                  unit: "₴",
                ),
              );
            }

            // Зсуваємо індекс для отримання правильного елемента з масиву витрат
            final costIndex = index - 1;

            // 2. ОСТАННІЙ ЕЛЕМЕНТ — Лоадер пагінації
            if (costIndex == _costs.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // 3. КАРТКИ ВИТРАТ
            final cost = _costs[costIndex];
            return _buildCostCard(cost);
          },
        ),
      ),
    );
  }

  Widget _buildCostCard(CostsDto cost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TTNeumorphicBox(
        padding: const EdgeInsets.only(left: 8, right: 24, top: 16, bottom: 16),
        child: Row(
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
                      // 🔥 Виводимо дату створення зліва/справа у верхньому рядку картки
                      if (cost.createdAt != null)
                        Text(
                          _formatDate(cost.createdAt),
                          style: TTTextStyle.subtitle.copyWith(
                            fontSize: 10,
                            color: TTColors.text_secondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cost.description.isNotEmpty
                        ? cost.description
                        : 'Без опису',
                    style: TTTextStyle.subtitle.copyWith(
                      fontSize: 13,
                      color: TTColors.text,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 🔥 Кнопка редагування доступна ТІЛЬКИ для адмінів
            if (_isAdmin) ...[
              const SizedBox(width: 8),
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
