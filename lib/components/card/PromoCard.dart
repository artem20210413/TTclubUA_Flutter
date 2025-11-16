// 2) ADD: виджет карточки (новый файл lib/components/PromoCard.dart)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tt_club_ua/config/default.dart';

import '../TTNeumorphicBox.dart';
import '../buttons/CircleButton.dart';

class PromoCard extends StatefulWidget {
  final String imagePath; // фоновая картинка (asset или http)
  final String title; // текст на карточке
  final VoidCallback onButtonTap; // действие по кнопке
  final bool enabled; // активна ли карточка
  const PromoCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onButtonTap,
    this.enabled = true,
  });

  @override
  State<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<PromoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = widget.imagePath.startsWith('http');

    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (widget.enabled) widget.onButtonTap();
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.45,
          width: MediaQuery.of(context).size.width * 0.90,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // фон
                Positioned.fill(child: ColoredBox(color: Colors.black)),
                Positioned.fill(
                  child: isNetwork
                      ? Image.network(widget.imagePath, fit: BoxFit.cover)
                      : Image.asset(widget.imagePath, fit: BoxFit.cover),
                ),
                //
                Positioned.fill(
                    child: ColoredBox(
                        color: _pressed ? Colors.black45 : Colors.transparent)),
                // текст
                Positioned(
                  left: 20,
                  bottom: 20,
                  right: 96, // чтобы не налезал на кнопку
                  child: Text(
                    widget.title,
                    style: TTTextStyle.title.copyWith(fontSize: 22),
                  ),
                ),
                //
                Positioned.fill(
                    child: ColoredBox(
                        color: widget.enabled
                            ? Colors.transparent
                            : Colors.black54)),

                // круглая кнопка PNG (меняет картинку при нажатии)
                if (widget.enabled)
                  Positioned(
                    top: 25,
                    right: 25,
                    child: SvgPicture.asset(
                      'assets/svg/arrow.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
