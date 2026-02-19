import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../api/routs/Dto/Draw/DrawDto.dart';
import '../../../../components/TTNeumorphicBox.dart';
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
        ? DateFormat('dd.MM.yyyy HH:mm').format(draw.registrationUntil!)
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
              borderRadius: 24,
            ),
            const SizedBox(height: 16),
            // Хедер картки зі статусом
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(draw.statusController.text),
                  if (draw.isParticipatingNotifier.value)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draw.titleController.text,
                    style: TTTextStyle.title.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    draw.descriptionController.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TTTextStyle.subtitle.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: 16),

                  // Інфо-панель: Призи та Час
                  Row(
                    children: [
                      _buildIconInfo(Icons.emoji_events_outlined, "${draw.prizes.length} призів"),
                      const SizedBox(width: 16),
                      _buildIconInfo(Icons.timer_outlined, formattedDate),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'active' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFE5B80B)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}