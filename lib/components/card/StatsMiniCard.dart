import 'package:flutter/material.dart';
import '../../config/default.dart';
import '../TTNeumorphicBox.dart';

class StatsMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const StatsMiniCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = TTColors.text_secondary,
  });

  @override
  Widget build(BuildContext context) {
    return TTNeumorphicBox(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      radius: 18,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TTTextStyle.subtitle.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TTTextStyle.title.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
