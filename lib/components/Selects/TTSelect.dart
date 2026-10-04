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

  /// Optional leading widget rendered before the label (e.g. a color swatch).
  /// When null, only the text label is shown (default behavior).
  final Widget? Function(T)? leadingBuilder;

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
    this.leadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = (textStyle ?? TTTextStyle.title18);
// 👇 Проверяем, что value реально есть в списке
    final bool hasValue = value != null && items.contains(value);
    final T? safeValue = hasValue ? value : null;

    return TTNeumorphicBox(
      padding: padding,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: safeValue,
          isExpanded: true,
          dropdownColor: dropdownColor ?? TTColors.card,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(icon, color: iconColor),
          style: baseStyle,

          // как рисовать выбранный в самом поле
          selectedItemBuilder: (context) {
            return items.map((item) {
              final label = labelBuilder(item);
              final leading = leadingBuilder?.call(item);
              final text = Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: baseStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
              return Align(
                alignment: Alignment.centerLeft,
                child: leading == null
                    ? text
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [leading, const SizedBox(width: 8), text],
                      ),
              );
            }).toList();
          },

          // элементы в выпадающем списке
          items: items.map((item) {
            final bool isSelected = item == value;
            final label = labelBuilder(item);
            final leading = leadingBuilder?.call(item);
            final text = Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: baseStyle.copyWith(
                color: isSelected ? TTColors.text : TTColors.text_secondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );

            return DropdownMenuItem<T>(
              value: item,
              child: leading == null
                  ? text
                  : Row(
                      children: [leading, const SizedBox(width: 8), text],
                    ),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ),
    );
  }
}
