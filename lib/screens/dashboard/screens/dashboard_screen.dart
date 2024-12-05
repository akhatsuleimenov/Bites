// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/screens/dashboard/widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, appController, _) {
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: appController.loadAppData,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0).copyWith(bottom: 12.0),
                    child: Text(
                      'Today\'s Dashboard',
                      style: AppTypography.headlineLarge,
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // Calorie and macro tracking
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CalorieCard(
                                  targetCalories:
                                      appController.nutritionPlan.calories,
                                  remainingCalories:
                                      appController.remainingMacros.calories,
                                ),
                                const SizedBox(height: 16),
                                NutritionGrid(
                                  targetNutrition: appController.nutritionPlan,
                                  remainingNutrition:
                                      appController.remainingMacros,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Weight progress card
                        SliverToBoxAdapter(
                          child: WeightProgressCard(
                            weightLogs: appController.weightLogs,
                            latestWeight: appController.latestWeight,
                            isMetric: appController.userProfile.isMetric,
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
                              if (appController.todaysMealLogs.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text('No meals logged today'),
                                );
                              }

                              final mealLog =
                                  appController.todaysMealLogs[index];
                              return MealLogCard(
                                mealLog: mealLog,
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  builder: (context) =>
                                      MealLogDetails(mealLog: mealLog),
                                ),
                              );
                            },
                            childCount: appController.todaysMealLogs.isEmpty
                                ? 1
                                : appController.todaysMealLogs.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'dashboardFAB',
            onPressed: () => _showAddOptions(context),
            backgroundColor: Colors.black,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddOptions(BuildContext context) {
    final appController = Provider.of<AppController>(context, listen: false);

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
                    icon: Icons.monitor_weight_outlined,
                    label: 'Log Weight',
                    onTap: () async {
                      Navigator.pop(context);
                      final TextEditingController weightController =
                          TextEditingController(
                        text: MeasurementHelper.convertWeight(
                          appController.latestWeight ?? 0,
                          appController.userProfile.isMetric,
                        ).toStringAsFixed(0),
                      );

                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Log Weight'),
                          content: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  'Weight (${MeasurementHelper.getWeightLabel(appController.userProfile.isMetric)})',
                              labelStyle:
                                  const TextStyle(color: AppColors.textPrimary),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.textPrimary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );

                      if (result == true && weightController.text.isNotEmpty) {
                        final weight = MeasurementHelper.standardizeWeight(
                          double.tryParse(weightController.text)!,
                          appController.userProfile.isMetric,
                        );
                        await appController.logWeight(weight);
                        await appController.loadAppData();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
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
                const SizedBox(width: 16),
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
