import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/api/routs/Dto/Event/EventDto.dart';

import '../../../../components/viewers/ImagesCarousel.dart';

class EventAdminCard extends StatelessWidget {
  final EventDto event;
  final Color accentColor;
  final VoidCallback onEdit;

  const EventAdminCard({
    super.key,
    required this.event,
    required this.accentColor,
    required this.onEdit,
  });

  String _typeLabel(String? type) {
    switch (type) {
      case 'club':
        return 'Клубна подія';
      case 'world':
        return 'Подія світу';
      case 'birthday':
        return 'День народження';
      default:
        return 'Подія';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = event.activeNotifier.value;
    final dateText = event.descriptionController.text;

    return Container(
      decoration: BoxDecoration(
        color: TTColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? accentColor.withOpacity(0.5)
              : TTColors.text_secondary.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Expanded(
          //   child:
          GestureDetector(
            onTapUp: (_) => onEdit(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Тип + статус
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event.eventType.name,
                        style: TTTextStyle.subtitle.copyWith(
                          fontSize: 11,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? 'Активна' : 'Неактивна',
                      style: TTTextStyle.subtitle.copyWith(
                        fontSize: 11,
                        color: isActive ? TTColors.success : TTColors.danger,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                ImagesCarousel(
                  images: event.images,
                  height: MediaQuery.of(context).size.width * 0.5,
                  borderRadius: 32,
                ),
                const SizedBox(height: 8),

                /// Название
                Text(
                  event.titleController.text,
                  style: TTTextStyle.title18,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                /// Дата
                if (dateText.isNotEmpty)
                  Text(
                    dateText,
                    style: TTTextStyle.subtitle.copyWith(fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // const SizedBox(width: 12),
          //
          // /// Кнопка редактирования
          // IconButton(
          //   icon: Icon(Icons.edit, color: accentColor),
          //   onPressed: onEdit,
          // ),
        ],
      ),
    );
  }
}
