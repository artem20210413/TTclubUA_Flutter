import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../Storage/Cache/DeviceInsetsCache.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

enum EventCategory { all, club, birthday, world }

class CalendarEvent {
  final DateTime date;
  final String title;
  final String? place;
  final EventCategory category;
  final TimeOfDay? time;
  final String? imageUrl;

  CalendarEvent({
    required this.date,
    required this.title,
    required this.category,
    this.place,
    this.time,
    this.imageUrl,
  });
}

class _CalendarState extends State<Calendar> {
  // ---------------- UI palette (заміняй на свої TTColors якщо є) -------------
  final Color bg = const Color(0xFF16181C);
  final Color card = const Color(0xFF1F2227);
  final Color textPrimary = TTColors.text;
  final Color textSecondary = TTColors.text_secondary;
  final Color textDart = TTColors.background_second;
  final Color ring = const Color(0xFF2C2F35);
  final Color dayInactive = const Color(0xFF2A2D33);
  final Color dotClub = const Color(0xFF8FD6FA); // блакитний
  final Color dotBirthday = const Color(0xFF98A9D4); // ліловий
  final Color dotMuted = const Color(0xFF767474); // сірий для інших

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

    _events = _mockEvents();
    _byDate = _groupByDate(_events);
  }

  // ---------------- Helpers ---------------------------------------------------
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
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EventCategory>(
          value: _selectedCategory,
          icon: const Icon(Icons.expand_more, color: Colors.white70),
          dropdownColor: card,
          borderRadius: BorderRadius.circular(16),
          style: TextStyle(color: textPrimary, fontSize: 16),
          items: const [
            DropdownMenuItem(
              value: EventCategory.all,
              child: Text('Усі події'),
            ),
            DropdownMenuItem(
              value: EventCategory.club,
              child: Text('Події клубу'),
            ),
            DropdownMenuItem(
              value: EventCategory.world,
              child: Text('Події світу'),
            ),
            DropdownMenuItem(
              value: EventCategory.birthday,
              child: Text('Дні народження'),
            ),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _selectedCategory = v);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        children: [
          // month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Попередній місяць',
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month - 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_left,
                    color: TTColors.text_secondary),
              ),
              Text(
                _monthTitle(_focusedMonth),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: 'Наступний місяць',
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month + 1, 1);
                  });
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
                  // margin: const EdgeInsets.only(top: 3),
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
    final events = _byDate[_stripTime(date)] ?? const [];
    final hasClub = events.any((e) => e.category == EventCategory.club);
    final hasBirthday = events.any((e) => e.category == EventCategory.birthday);
    final hasWorld = events.any((e) => e.category == EventCategory.world);

    // final bgColor = isSelected
    //     ? dotClub.withOpacity(0.25)
    //     : (hasAny ? const Color(0xFF242830) : dayInactive);
    Color bgColor;
    Color tColor;
    if (hasWorld) {
      bgColor = dotMuted;
      tColor = textDart;
    } else if (hasBirthday) {
      bgColor = dotBirthday;
      tColor = textDart;
    } else if (hasClub) {
      bgColor = dotClub;
      tColor = textDart;
    } else {
      bgColor = dayInactive;
      tColor = textPrimary;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedDate = _stripTime(date)),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(99),
          border: isSelected ? Border.all(color: textPrimary, width: 2) : null,
          // border: isToday ? Border.all(color: ring, width: 2) : null,
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
          'Усі події $dd.$mm.$yyyy',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Text(
              'Подій немає',
              style: TextStyle(color: textSecondary),
            ),
          ),
        for (final e in events) ...[
          _eventCard(e),
          const SizedBox(height: 12),
        ]
      ],
    );
  }

  Widget _eventCard(CalendarEvent e) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 96,
              height: 72,
              color: Colors.black26,
              child: e.imageUrl != null
                  ? Image.network(e.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.white38),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.time != null
                      ? '${_formatDayMonth(e.date)} • ${e.time!.format(context)}'
                      : _formatDayMonth(e.date),
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  e.title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (e.place != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    e.place!,
                    style: TextStyle(color: textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF262A31),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.white70),
          ),
        ],
      ),
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

  // ---------------- Mock ------------------------------------------------------
  List<CalendarEvent> _mockEvents() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month; // зроблю приклад на поточний/сусідні місяці
    DateTime d(int day) => DateTime(y, m, day);

    return [
      // CalendarEvent(
      //   date: d(2),
      //   title: 'TT Season Opening Drive',
      //   category: EventCategory.club,
      //   time: const TimeOfDay(hour: 11, minute: 0),
      //   place: 'Паркінг Ocean Plaza → Обухівська траса',
      //   imageUrl: 'https://picsum.photos/seed/tt1/300/200',
      // ),
      // CalendarEvent(
      //   date: d(16),
      //   title: 'Кава з TT Club',
      //   category: EventCategory.club,
      //   time: const TimeOfDay(hour: 10, minute: 30),
      //   place: 'UNIT.City',
      //   imageUrl: 'https://picsum.photos/seed/tt2/300/200',
      // ),
      // CalendarEvent(
      //   date: d(17),
      //   title: 'День народження Оксани',
      //   category: EventCategory.birthday,
      //   imageUrl: 'https://picsum.photos/seed/bd1/300/200',
      // ),
      // CalendarEvent(
      //   date: d(20),
      //   title: 'Нічний виїзд на дамбу',
      //   category: EventCategory.club,
      //   time: const TimeOfDay(hour: 21, minute: 0),
      //   place: 'Гаванський міст',
      //   imageUrl: 'https://picsum.photos/seed/tt3/300/200',
      // ),
      // CalendarEvent(
      //   date: d(24),
      //   title: 'День народження Ігора',
      //   category: EventCategory.birthday,
      //   imageUrl: 'https://picsum.photos/seed/bd2/300/200',
      // ),
    ];
  }
}
