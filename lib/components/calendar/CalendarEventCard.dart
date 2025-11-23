import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/TTNeumorphicBox.dart';

import 'package:tt_club_ua/pages/Nav/Calendar.dart';

import '../../pages/Nav/Calendar/CalendarEventDetailsPage.dart';

// ⬆️ здесь лежит класс CalendarEvent и функция formatTime
// если CalendarEvent вынесешь в другой файл — поправишь import

class CalendarEventCard extends StatelessWidget {
  final CalendarEvent event;
  final String dateLabel; // уже отформатированная дата "29 лис" и т.п.

  const CalendarEventCard({
    super.key,
    required this.event,
    required this.dateLabel,
  });

  String formatTime(TimeOfDay? t) {
    if (t == null) return '';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final e = event;

    final String topLine =
        e.time != null ? '$dateLabel • ${formatTime(e.time)}' : dateLabel;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CalendarEventDetailsPage(item: e.dto),
          ),
        );
      },
      child: TTNeumorphicBox(
        radius: 18,
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 16),
        child: Row(
          children: [
            // картинка
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.black26,
                child: e.imageUrl != null
                    ? Image.network(e.imageUrl!, fit: BoxFit.cover)
                    : Icon(Icons.image, color: TTColors.text_secondary),
              ),
            ),

            const SizedBox(width: 14),

            // текстовый блок
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // дата + час
                  Text(
                    topLine,
                    style: TTTextStyle.subtitle,
                  ),
                  const SizedBox(height: 4),

                  // заголовок
                  Text(
                    e.dto.title,
                    style: TTTextStyle.title18,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 4),

                  // опис
                  Text(
                    e.dto.description,
                    style: TTTextStyle.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),

                  // место (если є)
                  if (e.dto.place != null && e.dto.place!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      e.dto.place!,
                      style: TTTextStyle.subtitle,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // стрелочка
            SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: TTColors.text_secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
