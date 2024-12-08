import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bites/core/widgets/buttons.dart';

class ComparisonScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ComparisonScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Bites creates\nlong-term results',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Weight',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AspectRatio(
                      aspectRatio: 1.7,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[200],
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const titles = ['Month 1', 'Month 6'];
                                  if (value.toInt() == 0) {
                                    return Text(
                                      titles[0],
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  } else if (value.toInt() == 5) {
                                    return Text(
                                      titles[1],
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                                interval: 1,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Bites line
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 100),
                                FlSpot(1, 97),
                                FlSpot(2, 93),
                                FlSpot(3, 88),
                                FlSpot(4, 85),
                                FlSpot(5, 83),
                              ],
                              isCurved: true,
                              color: Colors.black,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: Colors.black,
                                  );
                                },
                                checkToShowDot: (spot, barData) {
                                  return spot.x == 0 || spot.x == 5;
                                },
                              ),
                            ),
                            // Traditional line
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 100),
                                FlSpot(1, 94),
                                FlSpot(2, 90),
                                FlSpot(3, 88),
                                FlSpot(4, 92),
                                FlSpot(5, 98),
                              ],
                              isCurved: true,
                              color: const Color(0xFFFF9B9B),
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          minX: 0,
                          maxX: 5,
                          minY: 80,
                          maxY: 105,
                          clipData: FlClipData.all(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Bites',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Text(
                              'Traditional Diet',
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFFFF9B9B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '80% of Bites users maintain their weight loss even 6 months later',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/onboarding/goal-speed',
                  arguments: userData,
                ),
                text: 'Next',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
