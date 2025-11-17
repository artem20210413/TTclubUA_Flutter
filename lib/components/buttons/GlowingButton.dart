import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt_club_ua/config/default.dart';

import '../../Storage/Cache/AccentColorCache.dart';
import '../TTLoading.dart';

class GlowingButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  Color? colorGrowing;
  final Color colorBackground;
  final bool isLoading;
  final double? width;
  final EdgeInsets? margin;

  GlowingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.colorGrowing,
    this.isLoading = false,
    this.width,
    this.margin,
    this.colorBackground = TTColors.button_background,
  });

  @override
  _GlowingButtonState createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton> {
  bool _isPressed = false;
  Color _default = Colors.white;
  Color colorGrowing = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadAccentColor();
  }

  Future<void> _loadAccentColor() async {
    // final prefs = await SharedPreferences.getInstance();
    // final raw = prefs.getInt('accent_color');
    // print(raw);
    setState(() {
      // widget.colorGrowing = raw != null ? Color(raw) : _default;
      widget.colorGrowing = AccentColorCache.accentColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradientColorBackgroundWithOpacity = _isPressed ? 0.0 : 0.85;
    final textColor = _isPressed ? Colors.black : widget.colorGrowing;
    return InkWell(
      borderRadius: BorderRadius.circular(300),
      onTap: widget.isLoading
          ? null
          : () {
              widget.onPressed();
              HapticFeedback.lightImpact();
              //   // HapticFeedback.lightImpact() — лёгкий импульс (классический “тап”).
              //   // HapticFeedback.mediumImpact() — средний импульс.
              //   // HapticFeedback.heavyImpact() — сильный импульс.
              //   // HapticFeedback.selectionClick() — клик для выбора.
              //   // HapticFeedback.vibrate() — полная вибрация устройства (может быть длинной).
            },
      onTapDown:
          widget.isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp:
          widget.isLoading ? null : (_) => setState(() => _isPressed = false),
      child: AnimatedContainer(
        margin: widget.margin,
        duration: Duration(milliseconds: 100),
        height: 57,
        width: widget.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 3.5,
            colors: [
              widget.colorBackground
                  .withOpacity(gradientColorBackgroundWithOpacity),
              widget.colorBackground
            ],
          ),
          borderRadius: BorderRadius.circular(300),
          border: Border.all(color: widget.colorGrowing ?? _default, width: 2),
          boxShadow: [
            BoxShadow(
              color: widget.colorGrowing?.withOpacity(0.7) ?? _default,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: widget.isLoading
            ? const TTLoading(
                size: 40,
              )
            : Text(
                widget.text,
                style: TextStyle(
                  color: textColor,
                  fontFamily: TTTextStyle.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
      ),
    );
  }
}
