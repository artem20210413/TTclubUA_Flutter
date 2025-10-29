// 2) ADD: виджет карточки (новый файл lib/components/PromoCard.dart)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

class PromoCard extends StatefulWidget {
  final String imagePath; // фоновая картинка (asset или http)
  final String title; // текст на карточке
  final VoidCallback onButtonTap; // действие по кнопке
  const PromoCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onButtonTap,
  });

  @override
  State<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<PromoCard> {
  bool _pressed = false;
  final String kCardBtnIdlePng = 'assets/ui/btn_card.png';
  final String kCardBtnPressedPng = 'assets/ui/btn_card_pressed.png';

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = widget.imagePath.startsWith('http');

    return Align(
      alignment: Alignment.center,
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
                Positioned.fill(child: ColoredBox(color: _pressed ? Colors.black45: Colors.transparent)),
              // Positioned.fill(
              //   child: DecoratedBox(
              //     decoration: BoxDecoration(
              //       gradient: RadialGradient(
              //         center: Alignment.center,
              //         radius: 1.0, // радиус виньетки (1.0 = вся ширина)
              //         colors: [
              //           Colors.transparent,            // центр — без затемнения
              //           Colors.black.withOpacity(0.6), // края — тёмные
              //         ],
              //         stops: const [0.6, 1.0], // где начинается затемнение
              //       ),
              //     ),
              //   ),
              // ),

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

              // круглая кнопка PNG (меняет картинку при нажатии)
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTap: widget.onButtonTap,
                  child: ClipOval(
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Image.asset(
                          _pressed ? kCardBtnPressedPng : kCardBtnIdlePng,
                          width: 44,
                          height: 44,
                          filterQuality: FilterQuality.high,
                        )
                        // Container(
                        //   width: 44,
                        //   height: 44,
                        //   decoration: BoxDecoration(
                        //     color: Colors.black.withOpacity(0.25),
                        //     shape: BoxShape.circle,
                        //     border: Border.all(
                        //       color: Colors.white.withOpacity(0.18),
                        //       width: 1.2,
                        //     ),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.35),
                        //         blurRadius: 12,
                        //         offset: const Offset(0, 4),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Center(
                        //     child: Image.asset(
                        //       _pressed ? kCardBtnPressedPng : kCardBtnIdlePng,
                        //       width: 44,
                        //       height: 44,
                        //       filterQuality: FilterQuality.high,
                        //     ),
                        //   ),
                        // ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
