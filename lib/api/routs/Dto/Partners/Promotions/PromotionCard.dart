import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../components/TTNeumorphicBox.dart';
import '../../../../../components/generalModule.dart';
import '../../../../../components/viewers/ImagesCarousel.dart';
import '../../../../../config/default.dart';
import '../PromotionDto.dart';

class PromotionCard extends StatelessWidget {
  final PromotionDto promotion;
  final Color accentColor;

  const PromotionCard({
    super.key,
    required this.promotion,
    required this.accentColor,
  });

  // Вспомогательный метод для форматирования даты (DD.MM.YYYY)
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = promotion.images.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TTNeumorphicBox(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Изображение (показываем только если есть список картинок) ---
            if (hasImages)
              Stack(
                children: [
                  ImagesCarousel(
                    images: promotion.images,
                    height: 180,
                    borderRadius: 24,
                  ),
                  // Бейдж эксклюзивности
                  if (promotion.exclusiveNotifier.value)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Text(
                          'EXCLUSIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  // Размер скидки
                  if (promotion.discountValueController.text.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          promotion.discountValueController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Период действия акции ---
                  if (promotion.startDate != null || promotion.endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: accentColor.withOpacity(0.8)),
                          const SizedBox(width: 6),
                          Text(
                            "${promotion.startDate != null ? _formatDate(promotion.startDate!) : '...'} — ${promotion.endDate != null ? _formatDate(promotion.endDate!) : '∞'}",
                            style: TTTextStyle.subtitle.copyWith(
                              fontSize: 12,
                              color: accentColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    promotion.titleController.text,
                    style: TTTextStyle.title18,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promotion.descriptionController.text,
                    style: TTTextStyle.subtitle,
                    maxLines: 4, // Увеличил, так как без фото места больше
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (promotion.promoCodeController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildPromoCodeAction(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeAction(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: promotion.promoCodeController.text));
        MessageModule(context, 'Промокод скопійовано!', MessageType.information);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: TTColors.background,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ПРОМОКОД',
                  style: TextStyle(fontSize: 9, color: TTColors.text_secondary, letterSpacing: 1),
                ),
                Text(
                  promotion.promoCodeController.text,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Icon(Icons.copy_rounded, color: accentColor, size: 20),
          ],
        ),
      ),
    );
  }
}