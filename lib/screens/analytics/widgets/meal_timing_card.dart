// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/core/widgets/cards.dart';

class MealTimingCard extends StatelessWidget {
  const MealTimingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final weeklyLogs = appController.weeklyMealLogs;

    // Group meals by hour of day
    final mealsByHour = <int, List<double>>{};
    for (final log in weeklyLogs) {
      final hour = log.dateTime.hour;
      mealsByHour.putIfAbsent(hour, () => []);
      mealsByHour[hour]!
          .add(log.foodInfo.nutritionalInfo.nutritionData.calories);
    }

    // Calculate average calories per hour
    final averageByHour = <int, double>{};
    mealsByHour.forEach((hour, calories) {
      averageByHour[hour] = calories.reduce((a, b) => a + b) / calories.length;
    });

    // Sort hours and create bar groups
    final sortedHours = averageByHour.keys.toList()..sort();

    // Find max calories for y-axis
    final maxCalories = averageByHour.values.isEmpty
        ? 1000.0 // Default max if no data
        : averageByHour.values
            .fold(0.0, (max, value) => value > max ? value : max);
    final yAxisInterval = (maxCalories / 4).ceilToDouble();

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
            'Average calories consumed by time of day (last 7 days)',
            style: AppTypography.bodySmall.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCalories + yAxisInterval,
                minY: 0,
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yAxisInterval,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final hour = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _formatHour(hour),
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yAxisInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: sortedHours.map((hour) {
                  return BarChartGroupData(
                    x: hour,
                    barRods: [
                      BarChartRodData(
                        toY: averageByHour[hour]!,
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
