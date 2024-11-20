// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/features/analytics/widgets/widgets.dart';
import 'package:nutrition_ai/features/dashboard/controllers/dashboard_controller.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DashboardController>(
          builder: (context, controller, _) {
            return RefreshIndicator(
              onRefresh: controller.loadDashboardData,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics',
                      style: AppTypography.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        children: const [
                          CaloriesTrendCard(),
                          SizedBox(height: 16),
                          MacroDistributionCard(),
                          SizedBox(height: 16),
                          GoalsProgressCard(),
                          SizedBox(height: 16),
                          MealTimingCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
