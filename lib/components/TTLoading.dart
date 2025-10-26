import 'dart:ui';
import 'package:flutter/material.dart';

import '../config/default.dart';

class TTLoading extends StatefulWidget {
  final double? size;

  const TTLoading({super.key, this.size = 80});

  @override
  State<TTLoading> createState() => _TTLoadingState();
}

class _TTLoadingState extends State<TTLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxSize = 80;
    final double available = widget.size ??
        (MediaQuery.of(context).size.shortestSide * 0.15).clamp(30, maxSize);

    return Center(
      child: SizedBox(
        width: available,
        height: available,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Размытие фона
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Кольцо
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Transform.rotate(
                  angle: _controller.value * 6.3,
                  child: CustomPaint(
                    painter: _TTRingPainter(),
                    size: Size(available * 0.85, available * 0.85),
                  ),
                );
              },
            ),
            Text(
              "TT",
              style: TextStyle(
                fontSize: available * 0.28,
                fontFamily: TTTextStyle.fontFamily,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                decoration: TextDecoration.none,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TTRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..shader = SweepGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect.deflate(size.width * 0.05), 0, 5.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
