import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/api/routs/Draw/DrawStatus.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/labels/TTLabel.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../config/default.dart';

class DrawCard extends StatelessWidget {
  final DrawDto draw;
  final Color accentColor;
  final VoidCallback onTap;

  const DrawCard({
    super.key,
    required this.draw,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = draw.registrationUntil != null
        ? DateFormat('dd MMM HH:mm', 'uk_UA').format(draw.registrationUntil!)
        // ? DateFormat('dd.MM.yy HH:mm').format(draw.registrationUntil!)
        : 'Дата не вказана';

    return GestureDetector(
      onTap: onTap,
      child: TTNeumorphicBox(
        padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImagesCarousel(
              images: draw.images,
              height: 180,
              borderRadius: 32,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (DrawStatus.active != draw.getStatus())
                    TTLabel(
                      text: draw.getStatus().label,
                      accentColor: draw.getStatus() == DrawStatus.planned
                          ? accentColor
                          : draw.getStatus().color,
                    ),
                  if (DrawStatus.active == draw.getStatus() &&
                      draw.registrationUntil != null)
                    Row(
                      children: [
                        Text('Дійсний до: ', style: TTTextStyle.subtitle),
                        const SizedBox(width: 6),
                        Text(formattedDate,
                            style: TTTextStyle.subtitle
                                .copyWith(color: TTColors.text)),
                      ],
                    ),
                  if (draw.isParticipatingNotifier.value)
                    TTLabel(
                        text: "Зареєстровано",
                        accentColor: DrawStatus.active == draw.getStatus()
                            ? TTColors.success
                            : TTColors.text_secondary,
                        margin: EdgeInsets.only(left: 8)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draw.titleController.text,
                  style: TTTextStyle.title18,
                ),
                const SizedBox(height: 8),
                Text(
                  draw.descriptionController.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TTTextStyle.subtitle.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.emoji_events_outlined,
                        size: 18, color: accentColor),
                    const SizedBox(width: 6),
                    Text("${draw.prizes.length} призів",
                        style: TTTextStyle.subtitle
                            .copyWith(color: TTColors.text)),
                    const Spacer(),
                    if (draw.allowMultipleWinsNotifier.value)
                      TTLabel(
                        text: "Мульти-виграш",
                        accentColor: accentColor,
                      ),
                    if (draw.isPublicNotifier.value)
                      TTLabel(
                          text: "Публічний",
                          accentColor: accentColor,
                          margin: EdgeInsets.only(left: 8)),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
