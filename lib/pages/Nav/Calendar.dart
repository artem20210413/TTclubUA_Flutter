import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../Storage/Cache/DeviceInsetsCache.dart';
import '../../Storage/UserStorage.dart';
import '../../api/routs/Dto/Event/CalendarItemDto.dart';
import '../../api/routs/events.dart';
import '../../components/Selects/TTSelect.dart';
import '../../components/TTLoading.dart';
import '../../components/TTNeumorphicBox.dart';
import '../../components/calendar/CalendarEventCard.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

enum EventCategory { all, club, birthday, world }

class CalendarEvent {
  final CalendarItemDto dto;
  final DateTime date;
  final EventCategory category;
  final TimeOfDay? time;

  CalendarEvent({
    required this.dto,
    required this.date,
    required this.category,
    this.time,
  });

  String? get imageUrl => dto.images.isNotEmpty ? dto.images.first : null;
}

class _CalendarState extends State<Calendar> {
  // ---------------- UI palette (заміняй на свої TTColors якщо є) -------------
  final Color bg = TTColors.background;
  final Color card = TTColors.card;
  final Color textPrimary = TTColors.text;
  final Color textSecondary = TTColors.text_secondary;
  final Color textDart = TTColors.background_second;
  final Color ring = const Color(0xFF2C2F35);
  final Color dayInactive = TTColors.card;
  final Color dotClub = const Color(0xFF8FD6FA); // блакитний
  final Color dotBirthday =  TTColors.text_secondary.withOpacity(0.3); // ліловий Color(0xFF98A9D4)
  final Color dotMuted = Color(0xFF98A9D4); //const Color(0xFF767474); // сірий для інших
  List<CalendarItemDto> _items = [];
  bool _isLoading = false;

  // ---------------- State -----------------------------------------------------
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  List<CalendarEvent> _events = const [];
  Map<DateTime, List<CalendarEvent>> _byDate = const {};

  EventCategory _selectedCategory = EventCategory.all;

  @override
  void initState() {
    super.initState();
    // перший день місяця для хедера
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    // обрана дата — «сьогодні» без часу
    _selectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    _loadCalendarForMonth(_focusedMonth);
  }

  CalendarEvent _mapDtoToEvent(CalendarItemDto dto) {
    EventCategory cat;
    switch (dto.type) {
      case 'event_ttclubua':
        cat = EventCategory.club;
        break;
      case 'event_world':
        cat = EventCategory.world;
        break;
      case 'birthday':
        cat = EventCategory.birthday;
        break;
      default:
        cat = EventCategory.world; // всё остальное
    }

    // строка "16:00" → TimeOfDay
    TimeOfDay? t;
    if (dto.time != null && dto.time!.isNotEmpty) {
      final parts = dto.time!.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        t = TimeOfDay(hour: h, minute: m);
      }
    }

    return CalendarEvent(
      date: dto.date ?? DateTime.now(),
      category: cat,
      time: t,
      dto: dto,
    );
  }

  // ---------------- Helpers ---------------------------------------------------

  Future<void> _loadCalendarForMonth(DateTime month) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final token = await UserStorage.getToken();

      // "2025-02"
      final monthStr =
          "${month.year}-${month.month.toString().padLeft(2, '0')}";

      final res = await CALENDAR_LIST(token, month: monthStr);

      if (res.statusCode != 200) {
        print('Calendar load error: ${res.statusCode}');
        return;
      }
      final body = jsonDecode(res.body);

      final List data = body['data'] as List; // или просто body, если API = []

      // 1) JSON → DTO
      _items = data
          .map((e) => CalendarItemDto.fromJson(e as Map<String, dynamic>))
          .toList();

      // 2) DTO → CalendarEvent
      _events = _items
          .where((i) => i.date != null)
          .map((i) => _mapDtoToEvent(i))
          .toList();

      // 3) групування по даті
      _byDate = _groupByDate(_events);
    } catch (e) {
      print('Calendar load exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<DateTime, List<CalendarEvent>> _groupByDate(List<CalendarEvent> items) {
    final map = <DateTime, List<CalendarEvent>>{};
    for (final e in items) {
      final k = _stripTime(e.date);
      map.putIfAbsent(k, () => []).add(e);
    }
    return map;
  }

  List<CalendarEvent> _eventsFor(DateTime day, EventCategory filter) {
    final all = _byDate[_stripTime(day)] ?? const [];
    if (filter == EventCategory.all) return all;
    return all.where((e) => e.category == filter).toList();
  }

  String _monthTitle(DateTime m) {
    const monthsUa = [
      'Січень',
      'Лютий',
      'Березень',
      'Квітень',
      'Травень',
      'Червень',
      'Липень',
      'Серпень',
      'Вересень',
      'Жовтень',
      'Листопад',
      'Грудень'
    ];
    return '${monthsUa[m.month - 1]} ${m.year}';
  }

  int _daysInMonth(DateTime m) {
    final firstNext = (m.month == 12)
        ? DateTime(m.year + 1, 1, 1)
        : DateTime(m.year, m.month + 1, 1);
    return firstNext.subtract(const Duration(days: 1)).day;
  }

  int _weekDay1to7(DateTime d) {
    // Flutter: Monday=1 ... Sunday=7  (standard ISO)
    final wd = DateTime(d.year, d.month, 1).weekday;
    return wd; // already ISO
  }

  // ---------------- UI --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
              top: DeviceInsetsCache.viewPaddingTop),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildFilter(),
              const SizedBox(height: 16),
              _buildCalendarCard(),
              const SizedBox(height: 16),
              _buildDayEvents(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.calendar_month, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          'Календар подій',
          style: TTTextStyle.title.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilter() {
    return TTSelect<EventCategory>(
      value: _selectedCategory,
      items: const [
        EventCategory.all,
        EventCategory.club,
        EventCategory.world,
        EventCategory.birthday,
      ],
      labelBuilder: (cat) {
        switch (cat) {
          case EventCategory.all:
            return 'Усі події';
          case EventCategory.club:
            return 'Події клубу';
          case EventCategory.world:
            return 'Події світу';
          case EventCategory.birthday:
            return 'Дні народження';
        }
      },
      onChanged: (v) {
        if (v != null) {
          setState(() => _selectedCategory = v);
        }
      },
    );
  }

  Widget _buildCalendarCard() {
    return TTNeumorphicBox(
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
      child: _isLoading
          ? const TTLoading()
          : Column(
              children: [
                // month header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Попередній місяць',
                      onPressed: () {
                        final newMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month - 1,
                          1,
                        );
                        setState(() {
                          _focusedMonth = newMonth;
                          _selectedDate = newMonth;
                        });
                        _loadCalendarForMonth(newMonth);
                      },
                      icon: const Icon(Icons.chevron_left,
                          color: TTColors.text_secondary),
                    ),
                    Text(
                      _monthTitle(_focusedMonth),
                      style: TTTextStyle.title18,
                    ),
                    IconButton(
                      tooltip: 'Наступний місяць',
                      onPressed: () {
                        final newMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                          1,
                        );
                        setState(() {
                          _focusedMonth = newMonth;
                          _selectedDate = newMonth;
                        });
                        _loadCalendarForMonth(newMonth);
                      },
                      icon: const Icon(Icons.chevron_right,
                          color: TTColors.text_secondary),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                _legend(),
                const SizedBox(height: 8),
                _weekdayHeader(),
                const SizedBox(height: 6),
                _monthGrid(),
              ],
            ),
    );
  }

  Widget _legend() {
    Widget item(Color c, String label) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TTTextStyle.subtitle
                    .copyWith(color: TTColors.text, fontSize: 12),
                // TextStyle(color: textSecondary, fontSize: 13, height: 1.2),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: item(dotClub, 'Події нашого клубу')),
              const SizedBox(width: 16),
              Expanded(child: item(dotBirthday, 'Дні народження')),
              const SizedBox(width: 16),
              Expanded(child: item(dotMuted, 'Події світу')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weekdayHeader() {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(d, style: TTTextStyle.subtitle),
                ),
              ))
          .toList(),
    );
  }

  Widget _monthGrid() {
    final days = _daysInMonth(_focusedMonth);
    final startOffset = _weekDay1to7(_focusedMonth) - 1; // 0..6
    final totalCells = startOffset + days;
    final rows = (totalCells / 7.0).ceil() * 7;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: rows,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        final dayNum = i - startOffset + 1;
        if (i < startOffset || dayNum > days) {
          return _emptyDayCell();
        }
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
        final isSelected = _stripTime(date) == _selectedDate;
        final isToday = _stripTime(date) == _stripTime(DateTime.now());
        final hasAny = (_byDate[_stripTime(date)] ?? []).isNotEmpty;

        return _dayCell(
          date: date,
          isSelected: isSelected,
          isToday: isToday,
          hasAny: hasAny,
        );
      },
    );
  }

  Widget _emptyDayCell() {
    return Container(
      decoration: BoxDecoration(
        color: dayInactive,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _dayCell({
    required DateTime date,
    required bool isSelected,
    required bool isToday,
    required bool hasAny,
  }) {
    final allEvents = _byDate[_stripTime(date)] ?? const [];

    // 1) Сначала решаем, какие события учитывать для покраски
    late final List<CalendarEvent> eventsForColor;

    if (_selectedCategory == EventCategory.all) {
      eventsForColor = allEvents;
    } else {
      eventsForColor =
          allEvents.where((e) => e.category == _selectedCategory).toList();
    }

    final hasClub = eventsForColor.any((e) => e.category == EventCategory.club);
    final hasBirthday =
        eventsForColor.any((e) => e.category == EventCategory.birthday);
    final hasWorld =
        eventsForColor.any((e) => e.category == EventCategory.world);

    Color bgColor;
    Color tColor;

    // 2) Логика подсветки
    if (_selectedCategory == EventCategory.all) {
      // как было раньше
      if (hasWorld) {
        bgColor = dotMuted;
        tColor = textDart;
      } else if (hasClub) {
        bgColor = dotClub;
        tColor = textDart;
      } else if (hasBirthday) {
        bgColor = dotBirthday;
        tColor = textPrimary;
      } else {
        bgColor = dayInactive;
        tColor = textPrimary;
      }
    } else {
      // фильтр по конкретному типу:
      if (eventsForColor.isNotEmpty) {
        switch (_selectedCategory) {
          case EventCategory.club:
            bgColor = dotClub;
            tColor = textDart;
            break;
          case EventCategory.birthday:
            bgColor = dotBirthday;
            tColor = textDart;
            break;
          case EventCategory.world:
            bgColor = dotMuted;
            tColor = textDart;
            break;
          case EventCategory.all:
            // не попадём сюда, но нужно для switch
            bgColor = dayInactive;
            tColor = textPrimary;
        }
      } else {
        // в этом дне нет событий выбранного типа
        bgColor = dayInactive;
        tColor = textPrimary;
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedDate = _stripTime(date)),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(99),
          border: isSelected
              ? Border.all(color: TTColors.text, width: 2)
              : isToday
                  ? Border.all(color: TTColors.text_secondary, width: 2)
                  : null,
        ),
        padding: const EdgeInsets.all(6),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '${date.day}'.padLeft(2, '0'),
            style: TTTextStyle.subtitle.copyWith(color: tColor),
          ),
        ),
      ),
    );
  }

  Widget _buildDayEvents() {
    final events = _eventsFor(_selectedDate, _selectedCategory);
    final dd = _selectedDate.day.toString().padLeft(2, '0');
    final mm = _selectedDate.month.toString().padLeft(2, '0');
    final yyyy = _selectedDate.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          events.isEmpty
              ? 'Події відсутні на $dd.$mm.$yyyy'
              : 'Усі події $dd.$mm.$yyyy',
          style: TTTextStyle.title18,
        ),
        const SizedBox(height: 12),
        for (final e in events) ...[
          CalendarEventCard(
            event: e,
            dateLabel: _formatDayMonth(e.date), // уже есть в твоём коде
          ),
          const SizedBox(height: 12),
        ]
      ],
    );
  }

  String _formatDayMonth(DateTime d) {
    const monthsUaShort = [
      'січ',
      'лют',
      'бер',
      'квіт',
      'трав',
      'чер',
      'лип',
      'сер',
      'вер',
      'жов',
      'лис',
      'гру'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${monthsUaShort[d.month - 1]}';
  }

}
