import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/core/models/food_entry.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoodEntryDetails extends StatelessWidget {
  final FoodEntry entry;

  const FoodEntryDetails({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (entry.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: entry.imageUrl,
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
                      entry.name,
                      style: AppTypography.headlineMedium,
                    ),
                    Text(
                      '${entry.calories} calories',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MacroNutrientsRow(macros: entry.nutritionPlan.macros),
        ],
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
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          '$value$unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class MacroNutrientsRow extends StatelessWidget {
  final MacroNutrients macros;

  const MacroNutrientsRow({super.key, required this.macros});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MacroDetail(
          label: 'Protein',
          value: macros.protein.toInt(),
          unit: 'g',
        ),
        MacroDetail(
          label: 'Carbs',
          value: macros.carbs.toInt(),
          unit: 'g',
        ),
        MacroDetail(
          label: 'Fat',
          value: macros.fats.toInt(),
          unit: 'g',
        ),
      ],
    );
  }
}
