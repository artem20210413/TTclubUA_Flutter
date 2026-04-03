import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Обов'язково для HapticFeedback
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/config/default.dart';

class TTRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color accentColor;
  final String iconPath;

  const TTRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.accentColor,
    // this.iconPath = 'assets/svg/arrow-counter-clockwise.svg',
    this.iconPath = 'assets/svg/circle_logo.svg',
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      offsetToArmed: 50.0,
      // Додаємо вібрацію при зміні стану
      onStateChanged: (change) {
        // Коли свайп досяг точки активації (Armed)
        if (change.didChange(to: IndicatorState.armed)) {
          HapticFeedback.mediumImpact();
        }
        // Коли почалося реальне завантаження
        if (change.didChange(to: IndicatorState.loading)) {
          HapticFeedback.lightImpact();
        }
      },
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            // Розрахунок позиції
            final double dy = controller.value * 50.0;

            return Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!controller.isIdle)
                  Positioned(
                    top: dy - 15,
                    child: Opacity(
                      opacity: controller.value.clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          // color: TTColors.card,
                          // shape: BoxShape.circle,
                          // border: Border.all(
                          //   color: accentColor.withOpacity(controller.isArmed ? 1.0 : 0.2),
                          //   width: 1.5,
                          // ),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: accentColor.withOpacity(0.2),
                          //     blurRadius: 10,
                          //     spreadRadius: 2,
                          //     offset: const Offset(0, 2),
                          //   )
                          // ],
                        ),
                        child: Transform.rotate(
                          angle: controller.isLoading
                              ? (DateTime.now().millisecondsSinceEpoch / 150)
                              : controller.value * 6.28,
                          child: SvgPicture.asset(
                            iconPath,
                            height: 50,
                            width: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Основний контент, який зсувається вниз
                Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}