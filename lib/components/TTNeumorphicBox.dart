import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

class TTNeumorphicBox extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color color;
  final Widget? child;

  const TTNeumorphicBox({
    super.key,
    this.height,
    this.width,
    this.padding = const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
    this.margin,
    this.radius = 40,
    this.color = TTColors.card,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      margin: margin,
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(-4, -4),
          ),
          BoxShadow(
            color: TTColors.card,
            spreadRadius: -4.0,
            blurRadius: 15.0,
          ),
        ],
      ),
      child: Container(
        padding: padding,
        child: child,
      ),
      // child: child,
    );
  }
}
