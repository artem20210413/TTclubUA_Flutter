import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String prefixText;
  final bool obscureText;
  final IconData? icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  final textColor = TTColors.text;
  final textSecondaryColor = TTColors.text_secondary;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixText = '',
    this.obscureText = false,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      decoration: BoxDecoration(
        color: TTColors.input,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: Offset(2, 2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            offset: Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          labelStyle: TextStyle(color: textSecondaryColor),
          border: InputBorder.none,
          icon: icon != null ? Icon(icon, color: textSecondaryColor) : null,
        ),
      ),
    );
  }
}
