import 'package:flutter/material.dart';

Widget LoadingModule = CircularProgressIndicator(
  color: Colors.black,
  strokeWidth: 4,
  strokeAlign: 5,
);

Widget CenterLoadingModule = Center(child: LoadingModule);

enum MessageType { information, success, error}

void MessageModule(BuildContext context, String text, MessageType type) {
  Color color;
  Color colorText = Colors.white;

  switch (type) {
    case MessageType.success:
      color = Colors.black;
      break;
    case MessageType.error:
      color = Colors.red;
      break;
    // case MessageType.warning:
    //   color = Colors.purple.shade100;
    //   colorText = Colors.black;
    //   break;
    default:
      color = Colors.black;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: colorText// Увеличиваем размер шрифта
          ),
        ),
      ),
      backgroundColor: color,
    ),
  );
}
