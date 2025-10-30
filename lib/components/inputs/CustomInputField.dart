import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String prefixText;
  final bool obscureText;

  final Widget? icon;
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

            Container(
              constraints: const BoxConstraints(minHeight: 57),
              decoration: BoxDecoration(
                // color: TTColors.input,
                color: TTColors.input,
                border: state.hasError
                    ? Border.all(color: TTColors.danger, width: 1)
                    : null,
                borderRadius: BorderRadius.circular(30), //state.hasError
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: label,
                  prefixText: prefixText,
                  labelStyle: TextStyle(color: textSecondaryColor),
                  border: InputBorder.none,
                  errorStyle: const TextStyle(height: 0),
                  // скрываем стандартный текст под полем
                  suffixIcon: icon,
                ),
                onChanged: (value) => state.didChange(value),
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
