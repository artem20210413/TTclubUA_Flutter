import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

import '../generalModule.dart';

Future<void> ConfirmAndRun({
  required BuildContext context,
  required Future<void> Function() action,
  String dialogTitle = 'Підтвердження',
  String dialogMessage = 'Ви впевнені, що хочете виконати дію?',
}) async {
  final bool? ok = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        backgroundColor: TTColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(dialogTitle,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        content: Text(dialogMessage,
            style: const TextStyle(color: Colors.white70, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати', style: TTTextStyle.subtitle),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Так',
                style: TTTextStyle.subtitle.copyWith(color: TTColors.text)),
          ),
        ],
      );
    },
  );

  if (ok != true) return;

  await action();
}
