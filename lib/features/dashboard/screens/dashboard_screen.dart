import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/models/meal_log.dart';
import 'package:nutrition_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:nutrition_ai/features/dashboard/widgets/calorie_card.dart';
import 'package:nutrition_ai/features/dashboard/widgets/meal_log_card.dart';
import 'package:nutrition_ai/features/dashboard/widgets/meal_log_details.dart';
import 'package:provider/provider.dart';

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
              child: CustomScrollView(
                slivers: [
                  // Header with user info
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Today\'s Nutrition',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

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
                      padding: EdgeInsets.all(16).copyWith(bottom: 8),
                      child: Text(
                        'Recent Meals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboardFAB',
        onPressed: () => Navigator.pushNamed(context, '/food-logging'),
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
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
