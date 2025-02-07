import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';

class WeeklyStreak extends StatelessWidget {
  final double targetCalories;
  final List<double> dailyCalories;

  const WeeklyStreak({
    super.key,
    required this.targetCalories,
    required this.dailyCalories,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isToday = index == DateTime.now().weekday - 1;
              final calories =
                  index < dailyCalories.length ? dailyCalories[index] : 0.0;
              final progress = calories / targetCalories;

              return Column(
                children: [
                  Text(
                    days[index],
                    style: TypographyStyles.subtitle(
                      color: isToday
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                      ),
                      if (calories > 0)
                        Container(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            value: progress > 1 ? 1 : progress,
                            backgroundColor: AppColors.progressBackground,
                            color: _getProgressColor(progress),
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      if (progress > 1)
                        Container(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            value: (progress - 1).clamp(0.0, 1.0),
                            backgroundColor: Colors.transparent,
                            color: Colors.red.withOpacity(0.3),
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          CustomPaint(
            size: const Size(double.infinity, 20),
            painter: StreakLinePainter(
              dailyCalories: dailyCalories,
              targetCalories: targetCalories,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.95 && progress <= 1.15) {
      return AppColors.primary;
    } else if (progress < 0.95) {
      return AppColors.primary;
    } else {
      return AppColors.primaryDark;
    }
  }
}

class StreakLinePainter extends CustomPainter {
  final List<double> dailyCalories;
  final double targetCalories;

  StreakLinePainter({
    required this.dailyCalories,
    required this.targetCalories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28 // Increased width to match circle size
      ..strokeCap = StrokeCap.round;

    final width = size.width - 52;
    final segmentWidth = width / 6;
    final centerY = size.height / 2 - 32; // Position in the middle of circles

    Path? streakPath;

    for (int i = 0; i < dailyCalories.length - 1; i++) {
      final x = 26 + (i * segmentWidth);
      final nextX = 26 + ((i + 1) * segmentWidth);
      final progress = dailyCalories[i] / targetCalories;
      final nextProgress = dailyCalories[i + 1] / targetCalories;

      if (progress >= 0.95 &&
          progress <= 1.15 &&
          nextProgress >= 0.95 &&
          nextProgress <= 1.15) {
        if (streakPath == null) {
          streakPath = Path()..moveTo(x, centerY);
        }
        streakPath.lineTo(nextX, centerY);
      } else if (streakPath != null) {
        canvas.drawPath(streakPath, paint); // Removed dashed path
        streakPath = null;
      }
    }

    if (streakPath != null) {
      canvas.drawPath(streakPath, paint); // Removed dashed path
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Helper class for dashed lines
class CircularIntervalList<T> {
  final List<T> _items;
  int _index = 0;

  CircularIntervalList(this._items);

  T get next {
    if (_items.isEmpty) throw Exception('Cannot get next from empty list');
    final item = _items[_index];
    _index = (_index + 1) % _items.length;
    return item;
  }
}

Path dashPath(Path path, {required CircularIntervalList<double> dashArray}) {
  final Path dashedPath = Path();
  final PathMetrics metrics = path.computeMetrics();

  for (PathMetric metric in metrics) {
    double distance = 0.0;
    bool draw = true;
    while (distance < metric.length) {
      final double len = dashArray.next;
      if (draw) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + len),
          Offset.zero,
        );
      }
      distance += len;
      draw = !draw;
    }
  }

  return dashedPath;
}
