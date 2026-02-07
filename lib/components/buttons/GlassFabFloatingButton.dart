import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// Імпортуйте ваші кольори та екран завантаження мерчу
// import 'package:your_project/theme/tt_colors.dart';
// import 'package:your_project/screens/merch_upload_screen.dart';

class GlassFabFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color accentColor;
  final String? iconPath;

  const GlassFabFloatingButton({
    super.key,
    required this.onPressed,
    this.iconPath = null,
    this.accentColor =
        const Color(0xFFE5B80B), // Встановіть ваш дефолтний акцентний колір
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: IconButton(
              // icon: icon ?? Icon(Icons.add, color: accentColor, size: 30),
              icon: SvgPicture.asset(
                iconPath ?? 'assets/svg/plus.svg',
                width: 30,
                height: 30,
                colorFilter: ColorFilter.mode(
                  accentColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onPressed),
        ),
      ),
    );
  }
}
