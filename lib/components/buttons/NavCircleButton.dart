import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/config/default.dart';

class NavCircleButton extends StatelessWidget {
  final String iconAsset;
  final bool isActive;
  final double? size;
  final double? sizeIcon;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double scale;

  const NavCircleButton({
    super.key,
    required this.iconAsset,
    this.isActive = false,
    this.size = 65,
    this.sizeIcon = 30,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.onTap,
    this.scale = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        child: Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                colors: [
                  TTColors.input,
                  TTColors.input.withOpacity(0.5),
                  Colors.transparent,
                ],
                stops: const [0.44, 0.8, 1.00],
              ),
              color: isActive
                  ? TTColors.input_focused.withOpacity(0.28)
                  : TTColors.input,
              border: Border.all(
                color:
                    isActive ? Colors.white.withOpacity(0.95) : TTColors.input,
                width: isActive ? 1.8 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints.tightFor(width: sizeIcon, height: sizeIcon),
                child: SvgPicture.asset(
                  iconAsset,
                  colorFilter: ColorFilter.mode(
                    isActive ? Colors.white : Colors.white.withOpacity(0.55),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
