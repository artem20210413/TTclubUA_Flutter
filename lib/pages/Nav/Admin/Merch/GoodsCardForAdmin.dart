import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/config/default.dart';
import '../../../../api/routs/Dto/Goods/GoodsDto.dart';
import '../../../../components/TTNeumorphicBox.dart';
import '../../../../components/buttons/GlowingButton.dart';
import '../../../../components/buttons/CircleButton.dart';
import '../../../../components/labels/StatusBadge.dart';
import '../../../../components/viewers/ImagesCarousel.dart';
import '../../../../components/card/CarImageBlock.dart';

class GoodsCardForAdmin extends StatelessWidget {
  final GoodsDto item;
  final VoidCallback onButton;
  final String textButton;
  final Color accentColor;

  const GoodsCardForAdmin({
    super.key,
    required this.item,
    required this.onButton,
    this.textButton = 'Детальніше',
    this.accentColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl =
        item.images.isNotEmpty ? item.images.first.url : null;
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TTNeumorphicBox(
          padding: EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 24),
          // radius: 32,
          child: GestureDetector(
            onTapUp: (_) => onButton(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Порядок:  ' + item.priorityController.text,
                      style: TTTextStyle.subtitle,
                      textAlign: TextAlign.start,
                    ),
                    StatusBadge(isActive: item.activeNotifier.value),
                  ],
                ),
                const SizedBox(height: 14),
                // --- Фото товару ---

                // CarImageBlock(
                //   uniqueKey: item.id.toString(),
                //   height: screenSize.width * 0.5,
                //   imageUrl: imageUrl,
                // ),
                ImagesCarousel(
                  images: item.images,
                  height: MediaQuery.of(context).size.width * 0.5,
                  borderRadius: 32,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   'Порядок:  ' + item.priorityController.text,
                    //   style: TTTextStyle.subtitle,
                    //   textAlign: TextAlign.start,
                    // ),

                    // const SizedBox(width: 24),
                    // /// 🔼 стрелка вверх
                    // GestureDetector(
                    //   // onTap: onUp,
                    //   child: Container(
                    //     padding: const EdgeInsets.all(8),
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: Colors.white12,
                    //     ),
                    //     child: const Icon(
                    //       Icons.keyboard_arrow_up_rounded,
                    //       color: Colors.white,
                    //       size: 26,
                    //     ),
                    //   ),
                    // ),
                    //
                    // const SizedBox(width: 24),
                    //
                    // /// 🔽 стрелка вниз
                    // GestureDetector(
                    //   // onTap: onDown,
                    //   child: Container(
                    //     padding: const EdgeInsets.all(8),
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: Colors.white12,
                    //     ),
                    //     child: const Icon(
                    //       Icons.keyboard_arrow_down_rounded,
                    //       color: Colors.white,
                    //       size: 26,
                    //     ),
                    //   ),
                    // ),
                  ],
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
                    // Expanded(
                    //   flex: 1,
                    //   child: GlowingButton(
                    //     text: textButton,
                    //     onPressed: onButton ?? () {},
                    //     colorGrowing: accentColor,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Positioned(
        //   right: 8,
        //   top: 0,
        //   child: CircleButton(
        //     accentColor: item.activeNotifier.value ? Colors.green : Colors.red,
        //     iconAsset: item.activeNotifier.value
        //         ? 'assets/svg/check_mark.svg'
        //         : 'assets/svg/circle-fill.svg',
        //   ),
        //   //   accentColor: item.activeNotifier.value ? Colors.green : Colors.red,
        //   //   iconAsset: item.activeNotifier.value ? 'assets/svg/check_mark.svg' : 'assets/svg/circle-fill.svg',
        //   //   // onTap: _pickAndUploadImage,
        //   // ),
        //   // CircleButton(
        // ),
        // Positioned(
        //   left: 15,
        //   top: 15,
        //   child: Text( item.priorityController.text, style: TTTextStyle.title, ),
        // )
      ],
    );
  }
}
