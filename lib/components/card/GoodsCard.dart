import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../api/routs/Dto/Goods/GoodsDto.dart';
import '../../components/TTNeumorphicBox.dart';
import '../../components/buttons/GlowingButton.dart';
import 'CarImageBlock.dart';

class GoodsCard extends StatelessWidget {
  final GoodsDto item;
  final VoidCallback? onDetails;
  final Color accentColor;

  const GoodsCard({
    super.key,
    required this.item,
    this.onDetails,
    this.accentColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl =
        item.images.isNotEmpty ? item.images.first.url : null;
    final screenSize = MediaQuery.of(context).size;

    return TTNeumorphicBox(
      padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
      // radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Фото товару ---

          CarImageBlock(
            uniqueKey: item.id.toString(),
            height: screenSize.width * 0.8,
            imageUrl: imageUrl,
          ),

          const SizedBox(height: 14),

          // --- Назва ---
          Text(
            item.titleController.text ?? '-',
            style: TTTextStyle.title18,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // --- Опис ---
          Text(
            item.descriptionController.text,
            style: TTTextStyle.subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // --- Ціна + кнопка ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.priceController.text != '')
                Row(
                  children: [
                    Text(
                      "${item.priceController.text} грн",
                      // тут під ціну краще завести окреме поле
                      style: TTTextStyle.title.copyWith(fontSize: 20),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              Expanded(
                flex: 1,
                child: GlowingButton(
                  text: "Детальніше",
                  onPressed: onDetails ?? () {},
                  colorGrowing: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
