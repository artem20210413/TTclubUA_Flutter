import 'package:flutter/material.dart';

import '../../config/default.dart';

class StatusBadge extends StatelessWidget {
  final bool isActive;

  const StatusBadge({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? TTColors.success : TTColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Активна' : 'Неактивна',
        style: TTTextStyle.subtitle.copyWith(
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }
}
