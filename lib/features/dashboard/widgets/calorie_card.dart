import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/models/food_entry.dart';
import 'package:nutrition_ai/features/dashboard/widgets/food_entry_details.dart';

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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$remainingCalories',
                  style: TextStyle(
                    fontSize: 24,
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
