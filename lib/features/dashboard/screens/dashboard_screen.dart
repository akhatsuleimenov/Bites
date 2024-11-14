// Flutter imports:
import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:nutrition_ai/core/models/meal_log.dart';
import 'package:nutrition_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:nutrition_ai/features/dashboard/widgets/calorie_card.dart';
import 'package:nutrition_ai/features/dashboard/widgets/meal_log_card.dart';
import 'package:nutrition_ai/features/dashboard/widgets/meal_log_details.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DashboardController>(
          builder: (context, controller, _) {
            return RefreshIndicator(
              onRefresh: controller.loadDashboardData,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0).copyWith(bottom: 12.0),
                    child: Text(
                      'Today\'s Nutrition',
                      style: AppTypography.headlineLarge,
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // Calorie and macro tracking
                        SliverToBoxAdapter(
                          child: CalorieCard(
                            remainingCalories: controller.remainingCalories,
                            remainingMacros: controller.remainingMacros,
                            goal: controller.userGoals.dailyCalories,
                          ),
                        ),

                        // Recent meals header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            child: Text(
                              'Recent Meals',
                              style: AppTypography.headlineMedium,
                            ),
                          ),
                        ),

                        // Meal logs list
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final mealLog = controller.todaysMealLogs[index];
                              return MealLogCard(
                                mealLog: mealLog,
                                onTap: () => _showMealDetails(context, mealLog),
                              );
                            },
                            childCount: controller.todaysMealLogs.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboardFAB',
        onPressed: () => Navigator.pushNamed(context, '/food-logging'),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMealDetails(BuildContext context, MealLog mealLog) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MealLogDetails(mealLog: mealLog),
    );
  }
}
