import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import 'package:tt_club_ua/components/TTNeumorphicBox.dart';

class TTSelect<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  final EdgeInsets padding;
  final TextStyle? textStyle;
  final Color? dropdownColor;
  final Color iconColor;
  final IconData icon;

  const TTSelect({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.textStyle,
    this.dropdownColor,
    this.iconColor = Colors.white70,
    this.icon = Icons.expand_more,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = (textStyle ?? TTTextStyle.title18);

    return TTNeumorphicBox(
      padding: padding,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: dropdownColor ?? TTColors.card,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(icon, color: iconColor),
          style: baseStyle,

          // как рисовать выбранный в самом поле
          selectedItemBuilder: (context) {
            return items.map((item) {
              final label = labelBuilder(item);
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // 👈 не даём вылезать
                  style: baseStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList();
          },

          // элементы в выпадающем списке
          items: items.map((item) {
            final bool isSelected = item == value;
            final label = labelBuilder(item);

            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: baseStyle.copyWith(
                  color: isSelected ? TTColors.text : TTColors.text_secondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ),
    );
  }
}
