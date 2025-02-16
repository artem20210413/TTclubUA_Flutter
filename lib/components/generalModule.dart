import 'package:flutter/material.dart';

Widget LoadingModule = CircularProgressIndicator(
  color: Colors.black,
  strokeWidth: 4,
  strokeAlign: 5,
);

Widget CenterLoadingModule = Center(child: LoadingModule);

enum MessageType { success, error }

void MessageModule(BuildContext context, String text, MessageType type) {
  Color color;

  switch (type) {
    case MessageType.success:
      color = Colors.black;
      break;
    case MessageType.error:
      color = Colors.red;
      break;
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
            fontSize: 15, // Увеличиваем размер шрифта
          ),
        ),
      ),
      backgroundColor: color,
    ),
  );
}
