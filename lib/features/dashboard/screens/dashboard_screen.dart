import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/cards.dart';
import 'package:nutrition_ai/app/routes.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DashboardScreen({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                'Dashboard',
                style: AppTypography.headlineMedium,
              ),
              actions: [
                IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DailyProgress(
                      targetCalories: userData['dailyCalories'] as int,
                      consumedCalories:
                          0, // This will come from state management
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Today\'s Nutrition',
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _NutritionGrid(
                      targetCalories: userData['dailyCalories'] as int,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Meals',
                          style: AppTypography.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to meal history
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _RecentMeals(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.foodLogging,
        ),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Log Meal'),
      ),
    );
  }
}

class _DailyProgress extends StatelessWidget {
  final int targetCalories;
  final int consumedCalories;

  const _DailyProgress({
    required this.targetCalories,
    required this.consumedCalories,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = consumedCalories / targetCalories;
    final remainingCalories = targetCalories - consumedCalories;

    return BaseCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calories Remaining',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remainingCalories.toString(),
                    style: AppTypography.headlineLarge,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Goal',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    targetCalories.toString(),
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionGrid extends StatelessWidget {
  final int targetCalories;

  const _NutritionGrid({
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final proteinTarget = (targetCalories * 0.3 / 4).round();
    final carbsTarget = (targetCalories * 0.4 / 4).round();
    final fatTarget = (targetCalories * 0.3 / 9).round();

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: [
        _MacroCard(
          title: 'Protein',
          consumed: 0,
          target: proteinTarget,
          unit: 'g',
          color: Colors.red[400]!,
        ),
        _MacroCard(
          title: 'Carbs',
          consumed: 0,
          target: carbsTarget,
          unit: 'g',
          color: Colors.blue[400]!,
        ),
        _MacroCard(
          title: 'Fat',
          consumed: 0,
          target: fatTarget,
          unit: 'g',
          color: Colors.orange[400]!,
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String title;
  final int consumed;
  final int target;
  final String unit;
  final Color color;

  const _MacroCard({
    required this.title,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final progressSize = availableHeight * 0.5;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: progressSize,
                width: progressSize,
                child: CircularProgressIndicator(
                  value: consumed / target,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  strokeWidth: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$consumed/$target$unit',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecentMeals extends StatelessWidget {
  const _RecentMeals();

  @override
  Widget build(BuildContext context) {
    // This will be replaced with actual meal data
    return const Center(
      child: Text(
        'No meals logged today',
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }
}
