import 'package:flutter/material.dart';

import '../../../config/default.dart';

/// Shared round on-screen control (zoom +/-, my location) for FR-019/FR-020.
class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MapControlButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TTColors.card,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: TTColors.text, size: 22),
        ),
      ),
    );
  }
}
