import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/cards.dart';
import 'package:nutrition_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MealTimingCard extends StatelessWidget {
  const MealTimingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<DashboardController>();
    final mealLogs = dashboardController.todaysMealLogs;

    // Group meals by hour of day
    final mealsByHour = <int, List<double>>{};
    for (final log in mealLogs) {
      final hour = log.dateTime.hour;
      mealsByHour.putIfAbsent(hour, () => []);
      mealsByHour[hour]!.add(log.totalCalories);
    }

    // Calculate average calories per hour
    final averageByHour = <int, double>{};
    mealsByHour.forEach((hour, calories) {
      averageByHour[hour] = calories.reduce((a, b) => a + b) / calories.length;
    });

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal Timing Pattern',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Average calories consumed by time of day',
            style: AppTypography.bodySmall.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: averageByHour.values.isEmpty
                    ? 100
                    : averageByHour.values.reduce((a, b) => a > b ? a : b) *
                        1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final hour = group.x.toInt();
                      final calories = averageByHour[hour] ?? 0;
                      return BarTooltipItem(
                        '${calories.toStringAsFixed(0)} kcal\n${_formatHour(hour)}',
                        AppTypography.bodySmall.copyWith(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final hour = value.toInt();
                        return Text(
                          _formatHour(hour),
                          style: AppTypography.bodySmall,
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: averageByHour.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Theme.of(context).primaryColor,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    final time = DateTime(2024, 1, 1, hour);
    return DateFormat('ha').format(time).toLowerCase();
  }
}
