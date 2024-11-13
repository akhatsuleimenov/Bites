import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/cards.dart';
import 'package:nutrition_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CaloriesTrendCard extends StatelessWidget {
  const CaloriesTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<DashboardController>();
    final mealLogs = dashboardController.todaysMealLogs;

    // Group meal logs by date and calculate daily totals
    final dailyTotals = <DateTime, double>{};
    for (final log in mealLogs) {
      final date =
          DateTime(log.dateTime.year, log.dateTime.month, log.dateTime.day);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + log.totalCalories;
    }

    // Sort dates and get last 7 days
    final sortedDates = dailyTotals.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    final last7Days = sortedDates.take(7).toList();

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
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
                        if (value.toInt() >= last7Days.length)
                          return const Text('');
                        final date = last7Days[value.toInt()];
                        return Text(
                          DateFormat('E').format(date),
                          style: AppTypography.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: last7Days.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        dailyTotals[entry.value] ?? 0,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
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
