import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import '../TTNeumorphicBox.dart';

class BigTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int? maxLines;
  final double minHeight;

  const BigTextInput({
    super.key,
    required this.controller,
    this.hint = 'Текст привітання...',
    this.minLines = 5,
    this.maxLines,
    this.minHeight = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return TTNeumorphicBox(
      radius: 32,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          minLines: minLines,
          maxLines: maxLines ?? null,
          // null = без ограничений
          style: TTTextStyle.subtitle.copyWith(color: TTColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TTTextStyle.subtitle.copyWith(color: TTColors.text_secondary),
            border: InputBorder.none,
            isCollapsed: true,
          ),
        ),
      ),
    );
  }
}
