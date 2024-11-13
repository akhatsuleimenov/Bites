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
    final weeklyLogs = dashboardController.weeklyMealLogs;

    // Calculate daily totals
    final dailyTotals = <DateTime, double>{};
    for (final log in weeklyLogs) {
      final date =
          DateTime(log.dateTime.year, log.dateTime.month, log.dateTime.day);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + log.totalCalories;
    }

    // Get last 7 days in reverse order (today to 7 days ago)
    final now = DateTime.now();
    final sortedDates = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index));
    });

    final spots = sortedDates.map((date) {
      return FlSpot(
        sortedDates.indexOf(date).toDouble(),
        dailyTotals[date] ?? 0,
      );
    }).toList();

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
                        if (value.toInt() >= sortedDates.length)
                          return const Text('');
                        final date = sortedDates[value.toInt()];
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
                    spots: spots,
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
