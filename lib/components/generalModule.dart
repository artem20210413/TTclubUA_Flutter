import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

Widget LoadingModule = CircularProgressIndicator(
  color: Colors.white,
  strokeWidth: 4,
  strokeAlign: 5,
);

Widget CenterLoadingModule = Center(child: LoadingModule);

enum MessageType { information, success, error }

void MessageModule(BuildContext context, String text, MessageType type) {
  final Color accent = switch (type) {
    MessageType.error => TTColors.danger,
    MessageType.success => TTColors.success,
    _ => TTColors.text,
  };

  ScaffoldMessenger.of(context).clearSnackBars();
  final bottom = MediaQuery.of(context).padding.bottom;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.fixed,              // полноширинно снизу
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      padding: EdgeInsets.zero,
      content: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(18, 14, 18, 14 + bottom),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF141414)],
          ),
          border: Border(top: BorderSide(color: accent.withOpacity(0.65), width: 1)),
          boxShadow: [
            BoxShadow(color: accent.withOpacity(0.35), blurRadius: 22, spreadRadius: -2),
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 12, offset: const Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            Icon(
              type == MessageType.error
                  ? Icons.error_outline_rounded
                  : type == MessageType.success
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: accent, size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TTTextStyle.subtitle.copyWith(color: TTColors.text, fontSize: 15, fontWeight: FontWeight.w600))// const TextStyle(color: TTColors.text, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    ),
  );
}


///----///
// enum MessageType { information, success, error }
//
// void MessageModule(BuildContext context, String text, MessageType type) {
//   Color background;
//   Color border;
//   IconData icon;
//
//   switch (type) {
//     case MessageType.success:
//       background = TTColors.background;
//       border = const Color(0xFF00FF99); // неоново-зелёный акцент успеха
//       icon = Icons.check_rounded;
//       break;
//
//     case MessageType.error:
//       background = TTColors.background;
//       border = const Color(0xFFFF3B30); // фирменный красный Apple-стиля
//       icon = Icons.error_outline_rounded;
//       break;
//
//     default:
//       background = TTColors.background;
//       border = Colors.white.withOpacity(0.3);
//       icon = Icons.info_outline_rounded;
//       break;
//   }
//
//   ScaffoldMessenger.of(context).clearSnackBars();
//
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       elevation: 0,
//       behavior: SnackBarBehavior.floating,
//       backgroundColor: Colors.transparent,
//       duration: const Duration(seconds: 3),
//       content: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//         decoration: BoxDecoration(
//           color: background,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: border.withOpacity(0.6), width: 1.2),
//           boxShadow: [
//             BoxShadow(
//               color: border.withOpacity(0.35),
//               blurRadius: 14,
//               spreadRadius: -2,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: border, size: 20),
//             const SizedBox(width: 10),
//             Flexible(
//               child: Text(
//                 text,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
///----///
// enum MessageType { information, success, error}
//
// void MessageModule(BuildContext context, String text, MessageType type) {
//   Color color;
//   Color colorText = Colors.white;
//
//   switch (type) {
//     case MessageType.success:
//       color = Colors.black;
//       break;
//     case MessageType.error:
//       color = Colors.red;
//       break;
//     // case MessageType.warning:
//     //   color = Colors.purple.shade100;
//     //   colorText = Colors.black;
//     //   break;
//     default:
//       color = Colors.black;
//       break;
//   }
//
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Center(
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 15,
//             color: colorText// Увеличиваем размер шрифта
//           ),
//         ),
//       ),
//       backgroundColor: color,
//     ),
//   );
// }
