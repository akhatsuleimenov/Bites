import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/cards.dart';
import 'package:nutrition_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:provider/provider.dart';

class GoalsProgressCard extends StatelessWidget {
  const GoalsProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<DashboardController>();
    final mealLogs = dashboardController.todaysMealLogs;
    final nutritionPlan = dashboardController.nutritionPlan;

    // Calculate daily averages for the last 7 days
    final now = DateTime.now();
    final last7Days = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 7));

    final recentLogs =
        mealLogs.where((log) => log.dateTime.isAfter(last7Days)).toList();

    double avgCalories = 0;
    double avgProtein = 0;
    double avgCarbs = 0;
    double avgFat = 0;

    if (recentLogs.isNotEmpty) {
      avgCalories =
          recentLogs.map((log) => log.totalCalories).reduce((a, b) => a + b) /
              7;
      avgProtein =
          recentLogs.map((log) => log.totalProtein).reduce((a, b) => a + b) / 7;
      avgCarbs =
          recentLogs.map((log) => log.totalCarbs).reduce((a, b) => a + b) / 7;
      avgFat =
          recentLogs.map((log) => log.totalFat).reduce((a, b) => a + b) / 7;
    }

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
            target: nutritionPlan.macros.protein,
            unit: 'g',
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          _GoalProgressItem(
            label: 'Average Carbs',
            current: avgCarbs,
            target: nutritionPlan.macros.carbs,
            unit: 'g',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _GoalProgressItem(
            label: 'Average Fat',
            current: avgFat,
            target: nutritionPlan.macros.fats,
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
