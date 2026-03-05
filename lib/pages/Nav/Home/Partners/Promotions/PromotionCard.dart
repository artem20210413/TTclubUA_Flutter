import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../api/routs/Dto/Partners/PromotionDto.dart';
import '../../../../../components/TTNeumorphicBox.dart';
import '../../../../../components/generalModule.dart';
import '../../../../../components/labels/TTLabel.dart';
import '../../../../../components/viewers/DateRangeWidget.dart';
import '../../../../../components/viewers/ImagesCarousel.dart';
import '../../../../../config/default.dart';

class PromotionCard extends StatelessWidget {
  final PromotionDto promotion;
  final Color accentColor;

  const PromotionCard({
    super.key,
    required this.promotion,
    required this.accentColor,
  });

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
              Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 16),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ImagesCarousel(
                            images: promotion.images,
                            height: MediaQuery.of(context).size.width * 0.5,
                            borderRadius: 40,
                          ),
                          // Размер скидки
                          if (promotion.discountValueController.text.isNotEmpty)
                            Positioned(
                              bottom: 12,
                              left: -4,
                              child: TTLabel(
                                text: promotion.discountValueController.text,
                                background: Colors.black.withOpacity(0.7),
                                accentColor: accentColor,
                                margin: const EdgeInsets.only(left: 15),
                              ),
                            ),

                          if (promotion.exclusiveNotifier.value)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: TTLabel(
                                text: 'TT Only',
                                background: Colors.black.withOpacity(0.7),
                                accentColor: accentColor,
                                margin: const EdgeInsets.only(left: 15),
                              ),
                            ),
                        ],
                      ),
                    ],
                  )),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Период действия акции ---

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DateRangeWidget(
                            startDate: promotion.startDate,
                            endDate: promotion.endDate,
                          ),
                        ),
                        if (!hasImages &&
                            promotion.discountValueController.text.isNotEmpty)
                          TTLabel(
                            text: promotion.discountValueController.text,
                            accentColor: accentColor,
                            margin: const EdgeInsets.only(right: 7, top: 2),
                            fontSize: 14,
                          ),
                        if (!hasImages && promotion.exclusiveNotifier.value)
                          TTLabel(
                            text: 'TT Only',
                            accentColor: accentColor,
                            margin: const EdgeInsets.only(left: 15),
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
        Clipboard.setData(
            ClipboardData(text: promotion.promoCodeController.text));
        MessageModule(
            context, 'Промокод скопійовано!', MessageType.information);
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
                  style: TextStyle(
                      fontSize: 9,
                      color: TTColors.text_secondary,
                      letterSpacing: 1),
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
