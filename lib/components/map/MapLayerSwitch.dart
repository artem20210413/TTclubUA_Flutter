import 'package:flutter/material.dart';

import '../../config/default.dart';
import '../../pages/Nav/Map/MapLayer.dart';

/// Creative animated segmented control for switching between the "our
/// location" and "fa-fa" map layers (FR-006/FR-007) — a sliding pill
/// indicator glides between the two options instead of a plain select.
class MapLayerSwitch extends StatelessWidget {
  final MapLayer activeLayer;
  final ValueChanged<MapLayer> onChanged;

  const MapLayerSwitch({
    super.key,
    required this.activeLayer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 180;
    const double height = 40;
    final isFaFa = activeLayer == MapLayer.fafa;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: TTColors.card,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment:
                isFaFa ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: TTColors.text,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _SwitchLabel(
                label: 'Ми',
                isActive: !isFaFa,
                onTap: () => onChanged(MapLayer.ours),
              ),
              _SwitchLabel(
                label: 'Фа-фа',
                isActive: isFaFa,
                onTap: () => onChanged(MapLayer.fafa),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SwitchLabel({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TTTextStyle.subtitle.copyWith(
              color: isActive ? TTColors.background : TTColors.text,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
