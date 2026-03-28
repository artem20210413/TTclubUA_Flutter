import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../TTNeumorphicBox.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String prefixText;
  final bool obscureText;
  final bool readOnly;

  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  final textColor = TTColors.text;
  final textSecondaryColor = TTColors.text_secondary;
  final ValueChanged<String>? onChanged;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixText = '',
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 текст ошибки над инпутом
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0, left: 12),
                child: Text(
                  state.errorText!,
                  style: TTTextStyle.subtitle
                      .copyWith(color: TTColors.danger, fontSize: 13),
                  // style: const TextStyle(color: TTColors.danger, fontSize: 13),
                ),
              ),
            TTNeumorphicBox(
              radius: 32,
              padding:
                  const EdgeInsets.only(left: 18, right: 16, top: 0, bottom: 0),
              child: TextFormField(
                readOnly: readOnly,
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                textInputAction: textInputAction ?? TextInputAction.done,
                onFieldSubmitted: onSubmitted,

                // style: TextStyle(color: readOnly ? textSecondaryColor : textColor),
                style: TTTextStyle.subtitle.copyWith(
                    fontSize: 16,
                    color: readOnly ? textSecondaryColor : textColor),
                decoration: InputDecoration(
                    labelText: label,
                    prefixText: prefixText,
                    // labelStyle: TextStyle(color: textSecondaryColor),
                    labelStyle: TTTextStyle.subtitle,
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                    suffixIcon: suffixIcon,
                    prefixIcon: prefixIcon),
                onChanged: (value) {
                  state.didChange(value); // ✅ для валидации FormField
                  onChanged?.call(value); // ✅ внешний колбэк
                },
              ),
            ),
          ],
        );
      },
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Container(
//     // height: 57,
//     constraints: const BoxConstraints(minHeight: 57),
//     decoration: BoxDecoration(
//       color: TTColors.input,
//       borderRadius: BorderRadius.circular(30),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.6),
//           offset: Offset(2, 2),
//           blurRadius: 6,
//         ),
//         BoxShadow(
//           color: Colors.white.withOpacity(0.05),
//           offset: Offset(-2, -2),
//           blurRadius: 6,
//         ),
//       ],
//     ),
//     padding: EdgeInsets.symmetric(horizontal: 20),
//     alignment: Alignment.center,
//     child: TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       obscureText: obscureText,
//       validator: validator,
//       style: TextStyle(color: textColor),
//       decoration: InputDecoration(
//         labelText: label,
//         prefixText: prefixText,
//         labelStyle: TextStyle(color: textSecondaryColor),
//         border: InputBorder.none,
//         suffixIcon: icon,
//       ),
//     ),
//   );
// }
}
