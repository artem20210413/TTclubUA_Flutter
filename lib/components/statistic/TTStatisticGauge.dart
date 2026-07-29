import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tt_club_ua/config/default.dart'; // Твої TTColors та TTTextStyle
import '../../Storage/Cache/AccentColorCache.dart';
import '../TTNeumorphicBox.dart';

class TTStatisticGauge extends StatelessWidget {
  final double value;
  final double total;
  final String unit;
  final double size;
  final String valueLabel;
  final String totalLabel;

  const TTStatisticGauge({
    super.key,
    required this.value,
    required this.total,
    this.unit = '₴',
    this.size = 200, // Діаметр напівкруга
    this.valueLabel = 'Наразі: ',
    this.totalLabel = '  •  зібрано з ',
  });

  @override
  Widget build(BuildContext context) {
    // final Color accentColor = AccentColorCache.accentColor;

    // Розрахунок відсотка для прогресу (від 0.0 до 1.0)
    double percentage = total > 0 ? (value / total) : 0.0;
    final int displayPercentage = (percentage * 100).toInt();
    percentage = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    final formatter = NumberFormat.decimalPattern('uk_UA');

    final String formattedValue = formatter.format(value.toInt());
    final String formattedTotal = formatter.format(total.toInt());
    Color accentColor;

    if (displayPercentage < 30) {
      accentColor = TTColors.danger;
    } else if (displayPercentage < 70) {
      accentColor = TTColors.warning;
    } else {
      accentColor = TTColors.success;
    }

    return
        // TTNeumorphicBox(
        // padding: const EdgeInsets.only(left: 8, right: 24, top: 16, bottom: 16),
        // child:
        Padding(
      padding: EdgeInsetsGeometry.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Область з напівкругом
          SizedBox(
            width: size,
            height: size / 1.35,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Малюємо дугу прогресу
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GaugePainter(
                      percentage: percentage,
                      activeColor: accentColor,
                      backgroundColor: TTColors.input,
                    ),
                  ),
                ),

                // Текст по центру всередині дуги (лише відсотки)
                Positioned(
                  bottom: 12,
                  child: Text(
                    '$displayPercentage%',
                    style: TTTextStyle.title.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Блок опису під колом (в один рядок)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TTTextStyle.title18.copyWith(
                fontSize: 14,
                color: TTColors.text_secondary,
              ),
              children: [
                TextSpan(text: valueLabel),
                TextSpan(
                  text: '${formattedValue} $unit',
                  style: TextStyle(
                      color: accentColor, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: totalLabel),
                TextSpan(
                  text: '${formattedTotal} $unit',
                  style: TextStyle(
                      color: TTColors.text, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color activeColor;
  final Color backgroundColor;

  _GaugePainter({
    required this.percentage,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 14.0;
    final double startAngle = math.pi * 0.85; // Початок дуги зліва внизу
    final double sweepAngle = math.pi * 1.3; // Розмах дуги

    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.width - strokeWidth,
    );

    // 1. Фонова дуга
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    // 2. Активний прогрес із легким свіченням
    final Paint activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint glowPaint = Paint()
      ..color = activeColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round;

    final double activeSweepAngle = sweepAngle * percentage;

    if (percentage > 0) {
      canvas.drawArc(rect, startAngle, activeSweepAngle, false, glowPaint);
      canvas.drawArc(rect, startAngle, activeSweepAngle, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
