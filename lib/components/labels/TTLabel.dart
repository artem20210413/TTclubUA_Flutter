import 'package:flutter/material.dart';

import '../../config/default.dart';

class TTLabel extends StatelessWidget {
  final String text;
  final Color accentColor;
  final Color? background;
  final EdgeInsets? margin;
  final double? fontSize;

  const TTLabel({
    super.key,
    required this.text,
    required this.accentColor,
    this.background,
    this.margin,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor,
        ),
      ),
      child: Text(
        text,
        style: TTTextStyle.subtitle.copyWith(
            fontWeight: FontWeight.bold,
            color: accentColor,
            fontSize: fontSize ?? 12),
      ),
    );
  }
}
