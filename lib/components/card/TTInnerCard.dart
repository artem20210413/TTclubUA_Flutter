import 'package:flutter/material.dart';

import '../../config/default.dart';

class TTInsetCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  const TTInsetCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.color = TTColors.input,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          // светлая тень снизу-справа (имитация света изнутри)
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 1,
            // inset: true, // 👈 делает тень внутренней (для Flutter 3.24+)
          ),
          // тёмная тень сверху-слева
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 1,
            // inset: true,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.85),
                color.withOpacity(1.0),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

