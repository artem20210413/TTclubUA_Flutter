import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt_club_ua/config/default.dart';

class TopActionCard extends StatefulWidget {
  const TopActionCard({
    super.key,
    required this.iconAsset,
    this.label = '',
    required this.onTap,
    this.size = 79,
    this.radius = 24,
    this.iconSize = 27,
    this.iconColor,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  final double size;
  final double radius;
  final double iconSize;
  final Color? iconColor;

  @override
  State<TopActionCard> createState() => _TopActionCardState();
}

class _TopActionCardState extends State<TopActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final localScaler =
    textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);

    final gradient = _isPressed
        ? const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        // Colors.black12,
        Colors.white10,
        Colors.white24,
        // Colors.white10,
      ],
    )
        : const RadialGradient(
      radius: 4.5,
      colors: [
        TTColors.card,
        Colors.black26,
        Colors.black54,
        Colors.black,
        Colors.black,
        Colors.black,
      ],
    );

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          padding: const EdgeInsets.all(14),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: localScaler),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  widget.iconAsset,
                  fit: BoxFit.scaleDown,
                  height: widget.iconSize,
                  colorFilter: ColorFilter.mode(
                    (widget.iconColor ?? Colors.white),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:tt_club_ua/config/default.dart';
//
// class TopActionCard extends StatelessWidget {
//   const TopActionCard({
//     super.key,
//     required this.iconAsset, // шлях до svg в assets
//     this.label = '', // підпис під іконкою (у 2 рядки)
//     required this.onTap, // дія при натисканні
//     this.size = 79, // ширина/висота картки
//     this.radius = 24, // скруглення
//     this.iconSize = 27, // розмір іконки
//     this.iconColor,
//   });
//
//   final String iconAsset;
//   final String label;
//   final VoidCallback onTap;
//
//   final double size;
//   final double radius;
//   final double iconSize;
//   final Color? iconColor;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     // мягко ограничим масштаб системного текста внутри карточки
//     final textScaler = MediaQuery.textScalerOf(context);
//     final localScaler =
//         textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);
//
//     return Semantics(
//       button: true,
//       label: label,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(radius),
//         child: Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             gradient: RadialGradient(
//               radius: 4.5,
//               colors: [
//                 TTColors.card,
//                 Colors.black26,
//                 Colors.black54,
//                 Colors.black,
//                 Colors.black,
//                 Colors.black,
//               ],
//             ),
//             borderRadius: BorderRadius.circular(radius),
//           ),
//           padding: const EdgeInsets.all(14),
//           child: MediaQuery(
//             data: MediaQuery.of(context).copyWith(textScaler: localScaler),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: iconSize, // резерв места под иконку
//                   child: Center(
//                     child: SvgPicture.asset(
//                       iconAsset,
//                       fit: BoxFit.scaleDown,
//                       colorFilter: ColorFilter.mode(
//                         (iconColor ?? Colors.white),
//                         BlendMode.srcIn,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
