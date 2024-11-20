// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:bytes/core/constants/app_typography.dart';
import 'package:bytes/features/dashboard/controllers/dashboard_controller.dart';
import 'package:bytes/shared/widgets/cards.dart';

class CaloriesTrendCard extends StatelessWidget {
  const CaloriesTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyLogs = context.watch<DashboardController>().weeklyMealLogs;

    // Use a Map to store daily totals more efficiently
    final dailyTotals = weeklyLogs.fold<Map<DateTime, double>>({}, (map, log) {
      final date =
          DateTime(log.dateTime.year, log.dateTime.month, log.dateTime.day);
      map[date] = (map[date] ?? 0) +
          log.foodInfo.nutritionalInfo.nutritionData.calories;
      return map;
    });

    // Get last 7 days in reverse order (today to 7 days ago)
    final now = DateTime.now();
    final sortedDates = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index));
    });

    // Create spots only for dates with data
    final spots = sortedDates.map((date) {
      final calories = dailyTotals[date] ?? 0;
      return FlSpot(
        sortedDates.indexOf(date).toDouble(),
        calories,
      );
    }).toList();

    // Find max calories for y-axis
    final maxCalories = dailyTotals.values.isEmpty
        ? 1000.0 // Default max if no data
        : dailyTotals.values
            .fold(0.0, (max, value) => value > max ? value : max);
    final yAxisInterval = (maxCalories / 4).ceilToDouble();

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calorie Trend',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxCalories + yAxisInterval,
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
                titlesData: FlTitlesData(
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
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= sortedDates.length) {
                          return const Text('');
                        }
                        final date = sortedDates[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('E').format(date),
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white);
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
