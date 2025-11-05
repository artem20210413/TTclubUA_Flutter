import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/config/default.dart';

import '../TTLoading.dart';

class CircleButton extends StatefulWidget {
  final String iconAsset;
  final double? size;
  final double? sizeIcon;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double scale;
  final bool isLoading;

  const CircleButton({
    super.key,
    required this.iconAsset,
    this.size = 65,
    this.sizeIcon = 30,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.onTap,
    this.scale = 0.8,
    this.isLoading = false,
  });

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = _pressed;

    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Transform.scale(
          scale: widget.scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: widget.size,
            height: widget.size,
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
              child: widget.isLoading
                  ? const TTLoading(
                      size: 50,
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                        width: widget.sizeIcon,
                        height: widget.sizeIcon,
                      ),
                      child: SvgPicture.asset(
                        widget.iconAsset,
                        colorFilter: ColorFilter.mode(
                          isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
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
