// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bytes/core/constants/app_typography.dart';
import 'package:bytes/features/dashboard/controllers/dashboard_controller.dart';
import 'package:bytes/shared/widgets/cards.dart';

class GoalsProgressCard extends StatelessWidget {
  const GoalsProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<DashboardController>();
    final weeklyLogs = dashboardController.weeklyMealLogs;
    final nutritionPlan = dashboardController.nutritionPlan;

    final totalCalories = weeklyLogs.fold(
        0.0,
        (sum, log) =>
            sum + log.foodInfo.nutritionalInfo.nutritionData.calories);
    final totalProtein = weeklyLogs.fold(0.0,
        (sum, log) => sum + log.foodInfo.nutritionalInfo.nutritionData.protein);
    final totalCarbs = weeklyLogs.fold(0.0,
        (sum, log) => sum + log.foodInfo.nutritionalInfo.nutritionData.carbs);
    final totalFat = weeklyLogs.fold(0.0,
        (sum, log) => sum + log.foodInfo.nutritionalInfo.nutritionData.fats);

    final avgCalories = totalCalories / 7;
    final avgProtein = totalProtein / 7;
    final avgCarbs = totalCarbs / 7;
    final avgFat = totalFat / 7;

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Goals Progress',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 24),
          _GoalProgressItem(
            label: 'Average Calories',
            current: avgCalories,
            target: nutritionPlan.calories.toDouble(),
            unit: 'kcal',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _GoalProgressItem(
            label: 'Average Protein',
            current: avgProtein,
            target: nutritionPlan.protein,
            unit: 'g',
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          _GoalProgressItem(
            label: 'Average Carbs',
            current: avgCarbs,
            target: nutritionPlan.carbs,
            unit: 'g',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _GoalProgressItem(
            label: 'Average Fat',
            current: avgFat,
            target: nutritionPlan.fats,
            unit: 'g',
            color: Colors.yellow,
          ),
        ],
      ),
    );
  }
}

class _GoalProgressItem extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;
  final Color color;

  const _GoalProgressItem({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium,
            ),
            Text(
              '${current.toStringAsFixed(1)}/${target.toStringAsFixed(0)} $unit',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
