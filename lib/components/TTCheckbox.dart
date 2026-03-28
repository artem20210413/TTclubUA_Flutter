import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

class TTCheckbox extends StatelessWidget {
  final ValueNotifier<bool> activeNotifier;
  final String label;
  final Color accentColor;
  final TextStyle? style;

  const TTCheckbox({
    super.key,
    required this.activeNotifier,
    this.label = 'Активний товар',
    this.style,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: activeNotifier,
          builder: (context, value, _) {
            return Checkbox(
              value: value,
              onChanged: (v) => activeNotifier.value = v ?? false,
              side: const BorderSide(color: Colors.white54, width: 1.2),
              activeColor: accentColor,
              checkColor: Colors.black,
            );
          },
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: style ??
              TTTextStyle.subtitle.copyWith(
                // fontSize: 16,
                color: TTColors.text,
              ),
        ),
      ],
    );
  }
}
