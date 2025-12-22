import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';
import '../TTNeumorphicBox.dart';

class BigTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final int minLines;
  final int? maxLines;
  final double minHeight;
  final String? Function(String?)? validator;
  final bool readOnly;

  const BigTextInput({
    super.key,
    required this.controller,
    this.hint = '...',
    this.label = 'Текст',
    this.minLines = 5,
    this.maxLines,
    this.readOnly = false,
    this.minHeight = 140.0,
    this.validator,
  });

  // required String label,
  // required TextEditingController controller,
  // String? hint,
  //     TextInputType? keyboardType,
  // int maxLines = 1,
  //     bool readOnly = false,
  // VoidCallback? onTap,
  //     String? Function(String?)? validator,
  //     Widget? suffix,

  @override
  Widget build(BuildContext context) {
    return TTNeumorphicBox(
      radius: 32,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: TextInputType.multiline,
            style: TTTextStyle.subtitle.copyWith(fontSize: 16, color: readOnly ? TTColors.text_secondary : TTColors.text),
            // style: TTTextStyle.subtitle.copyWith(
            //     color: readOnly ? TTColors.text_secondary : TTColors.text),
            // TextStyle(
            //   color: readOnly ? TTColors.text_secondary : TTColors.text,
            //   fontSize: 14,
            //   fontWeight: FontWeight.w600,
            // ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              labelText: label,
              labelStyle: TTTextStyle.subtitle,
              // labelStyle: TextStyle(
              //   color: TTColors.text_secondary,
              //   fontWeight: FontWeight.w600,
              // ),
              hintText: hint,
              hintStyle: TTTextStyle.subtitle,
            ),
            validator: validator,
          )),
    );
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
