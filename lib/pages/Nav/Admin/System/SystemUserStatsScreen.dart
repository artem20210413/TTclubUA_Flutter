import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../Storage/Cache/AccentColorCache.dart';
import '../../../../Storage/UserStorage.dart';
import '../../../../api/routs/root.dart';
import '../../../../api/routs/system.dart';
import '../../../../components/TTLoading.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/card/StatsMiniCard.dart';
import '../../../../components/generalModule.dart';
import '../../../../components/layout/TTScaffold.dart';
import '../../../../config/default.dart';

class SystemUserStatsScreen extends StatefulWidget {
  const SystemUserStatsScreen({super.key});

  @override
  State<SystemUserStatsScreen> createState() => _SystemUserStatsScreenState();
}

class _SystemUserStatsScreenState extends State<SystemUserStatsScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;

  Color accentColor = AccentColorCache.accentColor;

  SystemUserStatsDto? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final token = await UserStorage.getToken();
      final res = await API_SYSTEM_USER_STATS(token);

      final ok = await CHECK_API(res, context);
      if (!ok) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final dto = SystemUserStatsDto.fromJson(body);

      if (mounted) {
        setState(() {
          _stats = dto;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      MessageModule(
          context, 'Помилка завантаження статистики', MessageType.error);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await _load(silent: true);
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return TTScaffold(
      title: 'Статистика користувачів',
      body: _isLoading
          ? const TTLoading()
          : _stats == null
              ? Center(
                  child: Text(
                    'Немає даних',
                    style: TTTextStyle.subtitle,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: accentColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _headerTotal(_stats!),
                        const SizedBox(height: 12),
                        StatsMiniCard(
                          title: 'У додатку',
                          value: _stats!.authorizedUniqueUsersCount
                              .toString(),
                          icon: Icons.verified_user_outlined,
                          iconColor: accentColor,
                        ),
                        const SizedBox(height: 12),
                        _gridRow(
                          left: StatsMiniCard(
                            title: 'З авто',
                            value: _stats!.usersWithCarsCount.toString(),
                            icon: Icons.directions_car,
                          ),
                          right: StatsMiniCard(
                            title: 'Без авто',
                            value: _stats!.usersWithoutCarsCount.toString(),
                            icon: Icons.directions_car_filled_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _gridRow(
                          left: StatsMiniCard(
                            title: 'Активні за годину',
                            value: _stats!.activeUsersLastHourCount.toString(),
                            icon: Icons.bolt,
                          ),
                          right: StatsMiniCard(
                            title: 'Токени > 1',
                            value:
                                _stats!.usersWithMultipleTokensCount.toString(),
                            icon: Icons.key,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('Нові користувачі'),
                        const SizedBox(height: 10),
                        _newUsersCard(_stats!),
                        const SizedBox(height: 16),
                        _sectionTitle('Статуси'),
                        const SizedBox(height: 10),
                        _statusCard(_stats!),
                        const SizedBox(height: 16),
                        if (_isRefreshing)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Оновлення…',
                                style: TTTextStyle.subtitle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _headerTotal(SystemUserStatsDto s) {
    return TTNeumorphicBox(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.10),
              border:
                  Border.all(color: accentColor.withOpacity(0.35), width: 1),
            ),
            child: Icon(Icons.groups, color: accentColor.withOpacity(0.85)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Усього користувачів', style: TTTextStyle.subtitle),
                const SizedBox(height: 4),
                Text(
                  s.totalUsers.toString(),
                  style: TTTextStyle.title.copyWith(fontSize: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TTTextStyle.title18,
    );
  }

  Widget _gridRow({required Widget left, required Widget right}) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _newUsersCard(SystemUserStatsDto s) {
    return TTNeumorphicBox(
      padding: const EdgeInsets.only(top: 16, right: 24, left: 16, bottom: 16),
      radius: 18,
      child: Column(
        children: [
          _kvRow('Сьогодні', s.newUsersToday.toString()),
          const SizedBox(height: 8),
          _kvRow('Цього місяця', s.newUsersThisMonth.toString()),
          const SizedBox(height: 8),
          _kvRow('За останні 30 днів', s.newUsersLast30Days.toString()),
          const SizedBox(height: 8),
          _kvRow('Цього року', s.newUsersThisYear.toString()),
          const SizedBox(height: 8),
          _kvRow('За останні 365 днів', s.newUsersLast365Days.toString()),
        ],
      ),
    );
  }

  Widget _statusCard(SystemUserStatsDto s) {
    return TTNeumorphicBox(
      padding: const EdgeInsets.only(top: 16, right: 24, left: 16, bottom: 16),
      radius: 18,
      child: Column(
        children: [
          _kvRow('Активні', s.activeUsers.toString(),
              valueColor: TTColors.success),
          const SizedBox(height: 8),
          _kvRow('Неактивні', s.inactiveUsers.toString(),
              valueColor: TTColors.danger),
        ],
      ),
    );
  }

  Widget _kvRow(String k, String v, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: TTTextStyle.subtitle),
        Text(
          v,
          style: TTTextStyle.title18.copyWith(
            color: valueColor ?? TTColors.text,
          ),
        ),
      ],
    );
  }
}

// ---------------- DTO ----------------

class SystemUserStatsDto {
  final int totalUsers;

  final int activeUsersLastHourCount;
  final int authorizedUniqueUsersCount;
  final List<int> activeUsersLastHourIds;

  final int newUsersToday;
  final int newUsersThisMonth;
  final int newUsersLast30Days;
  final int newUsersThisYear;
  final int newUsersLast365Days;

  final int activeUsers;
  final int inactiveUsers;

  final int usersWithMultipleTokensCount;
  final List<int> usersWithMultipleTokensIds;

  final int usersWithoutCarsCount;
  final int usersWithCarsCount;

  SystemUserStatsDto({
    required this.totalUsers,
    required this.activeUsersLastHourCount,
    required this.authorizedUniqueUsersCount,
    required this.activeUsersLastHourIds,
    required this.newUsersToday,
    required this.newUsersThisMonth,
    required this.newUsersLast30Days,
    required this.newUsersThisYear,
    required this.newUsersLast365Days,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.usersWithMultipleTokensCount,
    required this.usersWithMultipleTokensIds,
    required this.usersWithoutCarsCount,
    required this.usersWithCarsCount,
  });

  factory SystemUserStatsDto.fromJson(Map<String, dynamic> json) {
    final activeLastHour =
        (json['active_users_last_hour'] ?? {}) as Map<String, dynamic>;
    final multiTokens =
        (json['users_with_multiple_tokens'] ?? {}) as Map<String, dynamic>;
    final newUsers = (json['new_users'] ?? {}) as Map<String, dynamic>;
    final dist =
        (json['user_status_distribution'] ?? {}) as Map<String, dynamic>;
    final withoutCars =
        (json['users_without_cars'] ?? {}) as Map<String, dynamic>;
    final withCars = (json['users_with_cars'] ?? {}) as Map<String, dynamic>;

    return SystemUserStatsDto(
      totalUsers: json['total_users'] ?? 0,
      authorizedUniqueUsersCount: json['authorized_unique_users'] ?? 0,
      activeUsersLastHourCount: activeLastHour['count'] ?? 0,
      activeUsersLastHourIds:
          (activeLastHour['user_ids'] as List<dynamic>? ?? [])
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList(),
      newUsersToday: newUsers['today'] ?? 0,
      newUsersThisMonth: newUsers['this_month'] ?? 0,
      newUsersLast30Days: newUsers['last_30_days'] ?? 0,
      newUsersThisYear: newUsers['this_year'] ?? 0,
      newUsersLast365Days: newUsers['last_365_days'] ?? 0,
      activeUsers: dist['active'] ?? 0,
      inactiveUsers: dist['inactive'] ?? 0,
      usersWithMultipleTokensCount: multiTokens['count'] ?? 0,
      usersWithMultipleTokensIds:
          (multiTokens['user_ids'] as List<dynamic>? ?? [])
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList(),
      usersWithoutCarsCount: withoutCars['count'] ?? 0,
      usersWithCarsCount: withCars['count'] ?? 0,
    );
  }
}
