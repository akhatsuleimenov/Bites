// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:bytes/core/constants/app_typography.dart';
import 'package:bytes/features/dashboard/controllers/dashboard_controller.dart';
import 'package:bytes/shared/widgets/cards.dart';

class MacroDistributionCard extends StatelessWidget {
  const MacroDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<DashboardController>();
    final mealLogs = dashboardController.todaysMealLogs;

    // Calculate total macros
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final log in mealLogs) {
      totalProtein += log.foodInfo.nutritionalInfo.nutritionData.protein;
      totalCarbs += log.foodInfo.nutritionalInfo.nutritionData.carbs;
      totalFat += log.foodInfo.nutritionalInfo.nutritionData.fats;
    }

    final totalMacros = totalProtein + totalCarbs + totalFat;

    // Calculate percentages
    final proteinPercentage =
        totalMacros > 0 ? (totalProtein / totalMacros) * 100 : 0;
    final carbsPercentage =
        totalMacros > 0 ? (totalCarbs / totalMacros) * 100 : 0;
    final fatPercentage = totalMacros > 0 ? (totalFat / totalMacros) * 100 : 0;

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macro Distribution',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: proteinPercentage.toDouble(),
                          color: Colors.red,
                          title: '${proteinPercentage.toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: carbsPercentage.toDouble(),
                          color: Colors.blue,
                          title: '${carbsPercentage.toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: fatPercentage.toDouble(),
                          color: Colors.yellow,
                          title: '${fatPercentage.toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MacroLegendItem(
                      color: Colors.red,
                      label: 'Protein',
                      value: '${totalProtein.toStringAsFixed(1)}g',
                    ),
                    const SizedBox(height: 12),
                    _MacroLegendItem(
                      color: Colors.blue,
                      label: 'Carbs',
                      value: '${totalCarbs.toStringAsFixed(1)}g',
                    ),
                    const SizedBox(height: 12),
                    _MacroLegendItem(
                      color: Colors.yellow,
                      label: 'Fat',
                      value: '${totalFat.toStringAsFixed(1)}g',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MacroLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall,
            ),
            Text(
              value,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
