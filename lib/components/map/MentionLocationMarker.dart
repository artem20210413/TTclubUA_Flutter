import 'package:flutter/material.dart';

import '../../config/default.dart';

/// "fa-fa" location marker: shows only the numeric count (individual point
/// or cluster total) — no extra text/icons (FR-018), sized to fit 1-5
/// digits without truncation (FR-019).
class MentionLocationMarker extends StatelessWidget {
  final int count;
  final bool isCluster;
  final VoidCallback? onTap;

  const MentionLocationMarker({
    super.key,
    required this.count,
    this.isCluster = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 5-digit worst case needs more horizontal room than a fixed circle;
    // a rounded pill keeps the digits from being clipped or overlapping,
    // kept as small/light as the text allows (no border, a faint shadow).
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCluster ? TTColors.text : TTColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$count',
          // Same size as the count label on the "ours" markers (CityMapMarker).
          style: TTTextStyle.title18.copyWith(
            fontSize: 16,
            color: isCluster ? TTColors.background : TTColors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}
