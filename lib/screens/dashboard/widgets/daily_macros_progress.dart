import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/widgets/cards.dart';

class DailyMacrosProgress extends StatelessWidget {
  final NutritionData targetNutrition;
  final NutritionData remainingNutrition;

  const DailyMacrosProgress({
    super.key,
    required this.targetNutrition,
    required this.remainingNutrition,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress for each macro (consumed / target)
    final proteinProgress =
        (targetNutrition.protein - remainingNutrition.protein) /
            targetNutrition.protein;
    final carbsProgress = (targetNutrition.carbs - remainingNutrition.carbs) /
        targetNutrition.carbs;
    final fatProgress =
        (targetNutrition.fats - remainingNutrition.fats) / targetNutrition.fats;

    // Calculate minimum height needed (2 * outerRadius + padding for text)
    final minimumHeight = (116.0 * 2) + 32; // 48px for text padding

    return BaseCard(
      // backgroundColor: AppColors.background,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: minimumHeight,
            child: CustomPaint(
              painter: MacrosProgressPainter(
                protein: proteinProgress,
                carbs: carbsProgress,
                fat: fatProgress,
                targetNutrition: targetNutrition,
                remainingNutrition: remainingNutrition,
                caloriesOnOutside: true,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (targetNutrition.calories - remainingNutrition.calories)
                          .toStringAsFixed(0),
                      style: TypographyStyles.h2(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'out of ${targetNutrition.calories.toStringAsFixed(0)} kcal',
                      style: TypographyStyles.subtitle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMacroLegend(),
        ],
      ),
    );
  }

  Widget _buildMacroLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MacroLegendItem(
          label: 'Fat',
          value:
              '${(targetNutrition.fats - remainingNutrition.fats).toInt()}/${targetNutrition.fats.toInt()}g',
          color: AppColors.fat,
        ),
        _MacroLegendItem(
          label: 'Protein',
          value:
              '${(targetNutrition.protein - remainingNutrition.protein).toInt()}/${targetNutrition.protein.toInt()}g',
          color: AppColors.protein,
        ),
        _MacroLegendItem(
          label: 'Carbs',
          value:
              '${(targetNutrition.carbs - remainingNutrition.carbs).toInt()}/${targetNutrition.carbs.toInt()}g',
          color: AppColors.carbs,
        ),
      ],
    );
  }
}

class _MacroLegendItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroLegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TypographyStyles.bodyMedium(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TypographyStyles.bodyMedium(
            color: color,
          ),
        ),
      ],
    );
  }
}

class MacrosProgressPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fat;
  final NutritionData targetNutrition;
  final NutritionData remainingNutrition;
  final bool caloriesOnOutside;

  MacrosProgressPainter({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.targetNutrition,
    required this.remainingNutrition,
    this.caloriesOnOutside = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = 116.0;
    final innerRadius = 98.0;
    final strokeWidth = 12.0;
    final gapAngle = 0.1;

    final caloriesRadius = caloriesOnOutside ? outerRadius : innerRadius;
    final macrosRadius = caloriesOnOutside ? innerRadius : outerRadius;

    void drawArc(
        double startAngle, double sweepAngle, Color color, double radius,
        {bool isProgress = false}) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = isProgress ? color : color.withOpacity(0.2);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gapAngle / 2),
        sweepAngle - gapAngle,
        false,
        paint,
      );
    }

    const double pi = 3.14159;
    const startAngle = -pi / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.grayBackground;

    canvas.drawCircle(center, caloriesRadius, trackPaint);

    final caloriesProgress =
        (targetNutrition.calories - remainingNutrition.calories) /
            targetNutrition.calories;
    drawArc(
      startAngle,
      2 * pi * caloriesProgress,
      AppColors.primary,
      caloriesRadius,
      isProgress: true,
    );

    final totalGrams =
        targetNutrition.carbs + targetNutrition.protein + targetNutrition.fats;
    final carbsRatio = targetNutrition.carbs / totalGrams;
    final proteinRatio = targetNutrition.protein / totalGrams;
    final fatRatio = targetNutrition.fats / totalGrams;

    const totalAngle = 2 * pi;

    final adjustedCarbsAngle = (totalAngle * carbsRatio) - gapAngle;
    final adjustedProteinAngle = (totalAngle * proteinRatio) - gapAngle;
    final adjustedFatAngle = (totalAngle * fatRatio) - gapAngle;

    final carbsStartAngle = startAngle;
    final proteinStartAngle = carbsStartAngle + adjustedCarbsAngle + gapAngle;
    final fatStartAngle = proteinStartAngle + adjustedProteinAngle + gapAngle;

    drawArc(carbsStartAngle, adjustedCarbsAngle, AppColors.carbs, macrosRadius);
    drawArc(proteinStartAngle, adjustedProteinAngle, AppColors.protein,
        macrosRadius);
    drawArc(fatStartAngle, adjustedFatAngle, AppColors.fat, macrosRadius);

    if (carbs > 0) {
      final clampedCarbs = carbs.clamp(0.0, 1.0);
      drawArc(
        carbsStartAngle,
        adjustedCarbsAngle * clampedCarbs,
        AppColors.carbs,
        macrosRadius,
        isProgress: true,
      );
    }

    if (protein > 0) {
      final clampedProtein = protein.clamp(0.0, 1.0);
      drawArc(
        proteinStartAngle,
        adjustedProteinAngle * clampedProtein,
        AppColors.protein,
        macrosRadius,
        isProgress: true,
      );
    }

    if (fat > 0) {
      final clampedFat = fat.clamp(0.0, 1.0);
      drawArc(
        fatStartAngle,
        adjustedFatAngle * clampedFat,
        AppColors.fat,
        macrosRadius,
        isProgress: true,
      );
    }
  }

  @override
  bool shouldRepaint(MacrosProgressPainter oldDelegate) {
    return oldDelegate.protein != protein ||
        oldDelegate.carbs != carbs ||
        oldDelegate.fat != fat ||
        oldDelegate.caloriesOnOutside != caloriesOnOutside;
  }
}
