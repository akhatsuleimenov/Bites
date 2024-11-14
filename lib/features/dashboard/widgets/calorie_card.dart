// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/core/models/food_entry.dart';

class CalorieCard extends StatelessWidget {
  final int remainingCalories;
  final MacroNutrients remainingMacros;
  final int goal;

  const CalorieCard({
    super.key,
    required this.remainingCalories,
    required this.remainingMacros,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    print('remainingCalories: $remainingCalories');
    print('goal: $goal');
    print('remainingCalories / goal: ${remainingCalories / goal}');
    print('1 - (remainingCalories / goal): ${1 - (remainingCalories / goal)}');
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Calories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calories Left',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$remainingCalories',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            LinearProgressIndicator(
              value: 1 - (remainingCalories / goal).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                remainingCalories > 0 ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 16),

            // Macros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MacroDetail(
                  label: 'Protein',
                  value: remainingMacros.protein.toInt(),
                  unit: 'g',
                ),
                MacroDetail(
                  label: 'Carbs',
                  value: remainingMacros.carbs.toInt(),
                  unit: 'g',
                ),
                MacroDetail(
                  label: 'Fat',
                  value: remainingMacros.fats.toInt(),
                  unit: 'g',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MacroDetail extends StatelessWidget {
  final String label;
  final int value;
  final String unit;

  const MacroDetail({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          '$value$unit',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
