import 'package:flutter/material.dart';
import '../../../../config/default.dart';
import '../../Helpers/TTFormatter.dart';

class DateRangeWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Color? color;
  final double fontSize;
  final double iconSize;

  const DateRangeWidget({
    super.key,
    this.startDate,
    this.endDate,
    this.color,
    this.fontSize = 12,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (startDate == null && endDate == null) return const SizedBox.shrink();

    final displayColor = color ?? TTColors.text_secondary;

    // Оборачиваем в Align, чтобы внутри Column(center) он ушел влево
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(
          //   Icons.calendar_today,
          //   size: iconSize,
          //   color: displayColor,
          // ),
          // const SizedBox(width: 6),
          Text(
            "${startDate != null ? 'З ' + TTFormatter.formatDateUI(startDate!) : ''}  ${endDate != null ? 'до ' + TTFormatter.formatDateUI(endDate!) : ''}",
            style: TTTextStyle.subtitle.copyWith(
              fontSize: fontSize,
              color: displayColor,
            ),
          ),
        ],
      ),
    );
  }
}
