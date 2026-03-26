import 'package:flutter/material.dart';
import 'package:tt_club_ua/api/routs/Dto/ExternalCars/ExternalCarDto.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../api/routs/Dto/Goods/GoodsDto.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/labels/TTLabel.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../components/card/CarImageBlock.dart';

class ExternalCarCard extends StatelessWidget {
  final ExternalCarDto item;
  final VoidCallback? onButton;
  final String textButton;
  final Color accentColor;

  const ExternalCarCard({
    super.key,
    required this.item,
    this.onButton,
    this.textButton = 'Детальніше',
    this.accentColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onButton ?? () {},
      child: TTNeumorphicBox(
        padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
        // radius: 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImagesCarousel(
              images: item.images,
              height: MediaQuery.of(context).size.width * 0.5,
              borderRadius: 32,
            ),
            const SizedBox(height: 14),

            Text(
              // "${item.title} ${item.year}",
              "${item.title}",
              style: TTTextStyle.title18,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),
            Builder(
              builder: (context) {
                // 1. Збираємо тільки ті поля, які не є порожніми
                final List<String> parts = [
                  item.generationName,
                  item.modificationName ?? '', // якщо modificationName nullable
                  item.equipmentName,
                ].where((str) => str.trim().isNotEmpty).toList();

                // 2. З'єднуємо їх через сепаратор
                final String fullText = parts.join('  •  ');

                // 3. Якщо тексту взагалі немає — не виводимо нічого або заглушку
                if (fullText.isEmpty) return const SizedBox.shrink();

                return Text(
                  fullText,
                  style: TTTextStyle.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                );
              },
            ),
            // --- Опис ---
            // Text(
            //   item.description!,
            //   style: TTTextStyle.subtitle,
            //   maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${item.race}",
                    style: TTTextStyle.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // Невеликий відступ між колонками
                Expanded(
                  child: Text(
                    "${item.gearboxName}",
                    style: TTTextStyle.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign:
                        TextAlign.right, // Притискаємо правий текст до краю
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${item.fuelName}",
                    style: TTTextStyle.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${item.cityName} (${item.regionName})",
                    style: TTTextStyle.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Розштовхує дітей по краях
              children: [
                // Ліва частина: Ціна
                Text(
                  "\$${item.priceUsd.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}",
                  style: TTTextStyle.title.copyWith(fontSize: 20),
                ),

                // Права частина: Лейбл (якщо є юзер)
                if (item.user != null)
                  TTLabel(
                    fontSize: 15,
                    text: "Свої",
                    accentColor: accentColor,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
