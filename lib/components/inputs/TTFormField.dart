import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/default.dart';
import '../TTNeumorphicBox.dart';

class TTFormField extends StatelessWidget {
  const TTFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TTNeumorphicBox(
      radius: 35,
      padding: const EdgeInsets.only(left: 20, top: 8, right: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly || onTap != null,
        onTap: onTap,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: readOnly ? TTColors.text_secondary : TTColors.text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(
            color: TTColors.text_secondary,
            fontWeight: FontWeight.w600,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: TTColors.text_secondary.withOpacity(0.7)),
          suffixIcon: suffix,
        ),
        validator: validator,
      ),
    );
  }
}
