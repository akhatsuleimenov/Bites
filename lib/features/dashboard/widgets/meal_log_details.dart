// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/models/food_model.dart';

class MealLogDetails extends StatelessWidget {
  final MealLog mealLog;

  const MealLogDetails({
    super.key,
    required this.mealLog,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (mealLog.imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: mealLog.imagePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealLog.foodInfo.nutritionalInfo.name,
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _NutrientInfo(
                            label: 'Calories',
                            value: mealLog
                                .foodInfo.nutritionalInfo.nutritionData.calories
                                .toString(),
                            unit: 'kcal',
                          ),
                          _NutrientInfo(
                            label: 'Protein',
                            value: mealLog
                                .foodInfo.nutritionalInfo.nutritionData.protein
                                .toString(),
                            unit: 'g',
                          ),
                          _NutrientInfo(
                            label: 'Carbs',
                            value: mealLog
                                .foodInfo.nutritionalInfo.nutritionData.carbs
                                .toString(),
                            unit: 'g',
                          ),
                          _NutrientInfo(
                            label: 'Fat',
                            value: mealLog
                                .foodInfo.nutritionalInfo.nutritionData.fats
                                .toString(),
                            unit: 'g',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                    'Ingredients (${mealLog.foodInfo.ingredients.length})'),
                children: mealLog.foodInfo.ingredients
                    .map((item) => _ItemCard(item: item))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final NutritionalInfo item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientInfo(
                  label: 'Calories',
                  value: item.nutritionData.calories.toString(),
                  unit: 'kcal',
                ),
                _NutrientInfo(
                  label: 'Protein',
                  value: item.nutritionData.protein.toString(),
                  unit: 'g',
                ),
                _NutrientInfo(
                  label: 'Carbs',
                  value: item.nutritionData.carbs.toString(),
                  unit: 'g',
                ),
                _NutrientInfo(
                  label: 'Fat',
                  value: item.nutritionData.fats.toString(),
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

class _NutrientInfo extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutrientInfo({
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
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          '$value$unit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
