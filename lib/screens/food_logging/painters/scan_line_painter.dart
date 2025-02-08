import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_colors.dart';

class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width * 0.8;
    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;
    final radius = 8.0;

    // Clip to rounded square area
    canvas.save();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, squareSize, squareSize),
      Radius.circular(radius),
    );
    canvas.clipRRect(rrect);

    final scanLineY =
        top + (squareSize * ((math.sin(progress * math.pi * 2) + 1) / 2));

    final isMovingDown = math.cos(progress * math.pi * 2) > 0;

    // Main gradient for the scanning effect
    final gradientHeight = 40.0; // Increased height for more visible effect
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: isMovingDown ? Alignment.topCenter : Alignment.bottomCenter,
        end: isMovingDown ? Alignment.bottomCenter : Alignment.topCenter,
        colors: [
          AppColors.primary.withOpacity(0),
          AppColors.primary.withOpacity(0.2),
          AppColors.primary.withOpacity(0.7),
          AppColors.primary.withOpacity(0.2),
          AppColors.primary.withOpacity(0),
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(
          left, scanLineY - gradientHeight / 2, squareSize, gradientHeight));

    // Draw the gradient effect
    canvas.drawRect(
      Rect.fromLTWH(
          left, scanLineY - gradientHeight / 2, squareSize, gradientHeight),
      gradientPaint,
    );

    // Draw the center line with a glow effect
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    canvas.drawLine(
      Offset(left, scanLineY),
      Offset(left + squareSize, scanLineY),
      linePaint,
    );

    // Restore canvas to remove clipping
    canvas.restore();
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
