import 'package:flutter/material.dart';

import '../config/default.dart';

/// Non-blocking error notification with a "Retry" action, per FR-016/FR-017/FR-021.
void showRetrySnackBar(
  BuildContext context,
  String message, {
  required VoidCallback onRetry,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: TTColors.card,
      duration: const Duration(seconds: 5),
      content: Text(message, style: TTTextStyle.subtitle.copyWith(color: TTColors.text)),
      action: SnackBarAction(
        label: 'Повторити',
        textColor: TTColors.text,
        onPressed: onRetry,
      ),
    ),
  );
}
