import 'package:flutter/material.dart';
import 'package:tt_club_ua/config/default.dart';

class GlowingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color colorGrowing;
  final Color colorBackground = TTColors.button_background;

  const GlowingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.colorGrowing = Colors.white,
    // required this.growingColor ,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // width: double.infinity,
        height: 57,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: RadialGradient(
              radius: 3,
              colors: [colorBackground.withOpacity(0.85), colorBackground]),
          borderRadius: BorderRadius.circular(300),
          border: Border.all(
            color: colorGrowing, // светлая граница
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: colorGrowing.withOpacity(0.7),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colorGrowing,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            // fontStyle: FontStyle.normal,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
