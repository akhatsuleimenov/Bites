import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_colors.dart';

class OverlayPainter extends CustomPainter {
  final bool isScanning;

  OverlayPainter({this.isScanning = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final squareSize = size.width * 0.8;
    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;
    final radius = 8.0;

    // Draw semi-transparent overlay with rounded corners
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, squareSize, squareSize),
        Radius.circular(radius),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final borderColor = isScanning ? AppColors.primary : Colors.white;

    // Draw corner guides
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cornerLength = squareSize * 0.1;
    final cornerRadius = cornerLength * 0.3;

    // Draw all four corners with rounded edges
    _drawCorner(canvas, Offset(left + radius, top + radius), cornerLength,
        cornerRadius, 0, cornerPaint);
    _drawCorner(canvas, Offset(left + squareSize - radius, top + radius),
        cornerLength, cornerRadius, 1, cornerPaint);
    _drawCorner(canvas, Offset(left + radius, top + squareSize - radius),
        cornerLength, cornerRadius, 3, cornerPaint);
    _drawCorner(
        canvas,
        Offset(left + squareSize - radius, top + squareSize - radius),
        cornerLength,
        cornerRadius,
        2,
        cornerPaint);
  }

  void _drawCorner(Canvas canvas, Offset position, double length, double radius,
      int quadrant, Paint paint) {
    final startAngle = quadrant * math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: position, radius: radius),
      startAngle,
      math.pi / 2,
      false,
      paint,
    );

    final horizontal =
        Offset(length * (quadrant == 1 || quadrant == 2 ? -1 : 1), 0);
    final vertical =
        Offset(0, length * (quadrant == 2 || quadrant == 3 ? -1 : 1));

    canvas.drawLine(
        position + horizontal.scale(radius / length, radius / length),
        position + horizontal,
        paint);
    canvas.drawLine(position + vertical.scale(radius / length, radius / length),
        position + vertical, paint);
  }

  @override
  bool shouldRepaint(OverlayPainter oldDelegate) =>
      isScanning != oldDelegate.isScanning;
}
