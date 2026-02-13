import 'package:flutter/material.dart';

import '../../../../api/routs/Dto/Partners/PromotionDto.dart';
import '../../../../config/default.dart';

class PromotionAdminCard extends StatelessWidget {
  final PromotionDto promotion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PromotionAdminCard({
    super.key,
    required this.promotion,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDate =
        promotion.startDate != null || promotion.endDate != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TTColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: promotion.activeNotifier.value
              ? const Color(0xFFE5B80B).withOpacity(0.5)
              : Colors.white10,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Верхня частина: Статус та Пріоритет
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildBadge(
                      promotion.activeNotifier.value ? "АКТИВНА" : "ПРИХОВАНА",
                      promotion.activeNotifier.value
                          ? Colors.green
                          : Colors.grey,
                    ),
                    if (promotion.exclusiveNotifier.value) ...[
                      const SizedBox(width: 8),
                      _buildBadge("EXCLUSIVE", const Color(0xFFE5B80B)),
                    ],
                  ],
                ),
                Text(
                  "Пріоритет: ${promotion.priorityController.text}",
                  style: TTTextStyle.subtitle.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ),

          // Основний контент
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.titleController.text.isEmpty
                      ? "Без назви"
                      : promotion.titleController.text,
                  style: TTTextStyle.title.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  promotion.descriptionController.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TTTextStyle.subtitle.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),

                // Сітка з деталями (Знижка, Промокод)
                Row(
                  children: [
                    _buildInfoBlock("Знижка",
                        promotion.discountValueController.text, Icons.percent),
                    const SizedBox(width: 20),
                    _buildInfoBlock(
                        "Промокод",
                        promotion.promoCodeController.text.isEmpty
                            ? "—"
                            : promotion.promoCodeController.text,
                        Icons.qr_code),
                  ],
                ),

                const SizedBox(height: 16),
                if (hasDate) _buildDateRange(),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 32),

          // Кнопки керування
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    label: const Text("Редагувати",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onDelete,
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFFE5B80B)),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDateRange() {
    String start = promotion.startDate != null
        ? "${promotion.startDate!.day}.${promotion.startDate!.month}.${promotion.startDate!.year}"
        : "—";
    String end = promotion.endDate != null
        ? "${promotion.endDate!.day}.${promotion.endDate!.month}.${promotion.endDate!.year}"
        : "—";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: Colors.white38),
          const SizedBox(width: 8),
          Text("$start — $end",
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
