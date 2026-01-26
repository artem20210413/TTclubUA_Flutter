import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/api/routs/Dto/Partners/PartnerDto.dart';

import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/labels/StatusBadge.dart';
import '../../../../components/viewers/ImagesCarousel.dart';

class PartnerAdminCard extends StatelessWidget {
  final PartnerDto partner;
  final Color accentColor;
  final VoidCallback onEdit;

  const PartnerAdminCard({
    super.key,
    required this.partner,
    required this.accentColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Використовуємо ValueNotifier для миттєвого відображення статусу в адмінці
    final isActive = partner.activeNotifier.value;

    return GestureDetector(
      onTap: onEdit,
      child: TTNeumorphicBox(
        padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Верхня панель: бейдж акцій та статус
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (partner.hasPromotionsActual)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      'АКЦІЇ',
                      style: TTTextStyle.subtitle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                StatusBadge(isActive: isActive),
              ],
            ),

            const SizedBox(height: 12),

            /// Зображення партнера (логотип/фото)
            ImagesCarousel(
              images: partner.images,
              height: MediaQuery.of(context).size.width * 0.4,
              borderRadius: 24,
            ),

            const SizedBox(height: 12),

            /// Назва та опис
            Text(
              partner.titleController.text, // Беремо дані безпосередньо з контролера DTO
              style: TTTextStyle.title18,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            if (partner.descriptionController.text.isNotEmpty)
              Text(
                partner.descriptionController.text,
                style: TTTextStyle.subtitle.copyWith(fontSize: 12, color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            /// Пріоритет (службова інфо для адміна)
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Пріоритет: ${partner.priorityController.text}",
                style: TTTextStyle.subtitle.copyWith(fontSize: 10, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}