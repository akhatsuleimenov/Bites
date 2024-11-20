// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bytes/core/constants/app_typography.dart';
import 'package:bytes/core/models/food_models.dart';
import 'package:bytes/features/dashboard/controllers/dashboard_controller.dart';
import 'package:bytes/features/dashboard/widgets/calorie_card.dart';
import 'package:bytes/features/dashboard/widgets/meal_log_card.dart';
import 'package:bytes/features/dashboard/widgets/meal_log_details.dart';

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
                            remainingMacros: controller.remainingMacros,
                            goal: controller.nutritionPlan.calories,
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
                              if (controller.todaysMealLogs.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text('No meals logged today'),
                                );
                              }

                              final mealLog = controller.todaysMealLogs[index];
                              return MealLogCard(
                                mealLog: mealLog,
                                onTap: () => _showMealDetails(context, mealLog),
                              );
                            },
                            childCount: controller.todaysMealLogs.isEmpty
                                ? 1
                                : controller.todaysMealLogs.length,
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
        onPressed: () => _showAddOptions(context),
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

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: 'Scan food',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/food-logging');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionButton(
                    context,
                    icon: Icons.edit_outlined,
                    label: 'Manual entry',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/manual-entry');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    context,
                    icon: Icons.fitness_center_outlined,
                    label: 'Log exercise',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionButton(
                    context,
                    icon: Icons.search_outlined,
                    label: 'Food Database',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.grey[100],
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Colors.grey[200],
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Colors.black87,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
