// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/core/models/meal_log.dart';
import 'package:nutrition_ai/core/services/firebase_service.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

class FoodLoggingResultsScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResults;

  const FoodLoggingResultsScreen({
    super.key,
    required this.imagePath,
    required this.analysisResults,
  });

  @override
  State<FoodLoggingResultsScreen> createState() =>
      _FoodLoggingResultsScreenState();
}

class _FoodLoggingResultsScreenState extends State<FoodLoggingResultsScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedMealType = 'Lunch';

  final List<String> _mealTypes = [
    'Breakfast',
    'Morning Snack',
    'Lunch',
    'Afternoon Snack',
    'Dinner',
    'Evening Snack',
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showMealTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Meal Type',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 16),
              ...List.generate(
                _mealTypes.length,
                (index) => ListTile(
                  title: Text(_mealTypes[index]),
                  trailing: _selectedMealType == _mealTypes[index]
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () {
                    setState(() => _selectedMealType = _mealTypes[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMealLog() async {
    try {
      final items = widget.analysisResults['items'] as List;

      // Combine selected date and time
      final DateTime combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      final foodItems = items.map((item) {
        final food = item['food'][0];
        final foodInfo = food['food_info'];
        final quantity = foodInfo['quantity'] as double;

        // Calculate total nutrition for this item
        final itemCalories =
            (foodInfo['nutrition']['calories_100g'] as double) * quantity / 100;
        final itemProtein =
            (foodInfo['nutrition']['proteins_100g'] as double) * quantity / 100;
        final itemCarbs =
            (foodInfo['nutrition']['carbs_100g'] as double) * quantity / 100;
        final itemFat =
            (foodInfo['nutrition']['fat_100g'] as double) * quantity / 100;

        // Add to meal totals
        totalCalories += itemCalories;
        totalProtein += itemProtein;
        totalCarbs += itemCarbs;
        totalFat += itemFat;

        // Handle ingredients
        final ingredients =
            (food['ingredients'] as List? ?? []).map((ingredient) {
          final ingredientInfo = ingredient['food_info'];
          final ingQuantity = ingredient['quantity'] as double;

          final ingCalories =
              (ingredientInfo['nutrition']['calories_100g'] as double) *
                  ingQuantity /
                  100;
          final ingProtein =
              (ingredientInfo['nutrition']['proteins_100g'] as double) *
                  ingQuantity /
                  100;
          final ingCarbs =
              (ingredientInfo['nutrition']['carbs_100g'] as double) *
                  ingQuantity /
                  100;
          final ingFat = (ingredientInfo['nutrition']['fat_100g'] as double) *
              ingQuantity /
              100;

          return Ingredient(
            name: ingredientInfo['display_name'],
            quantity: ingQuantity,
            grade: ingredientInfo['fv_grade'],
            totalNutrition: {
              'calories': ingCalories,
              'protein': ingProtein,
              'carbs': ingCarbs,
              'fat': ingFat,
            },
          );
        }).toList();

        return FoodItem(
          name: foodInfo['display_name'],
          quantity: quantity,
          grade: foodInfo['fv_grade'],
          totalNutrition: {
            'calories': itemCalories,
            'protein': itemProtein,
            'carbs': itemCarbs,
            'fat': itemFat,
          },
          ingredients: ingredients,
        );
      }).toList();

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final mealLog = MealLog(
        userId: userId,
        dateTime: combinedDateTime,
        mealType: _selectedMealType,
        items: foodItems,
        imagePath: widget.imagePath,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        analysisId: widget.analysisResults['analysis_id'],
      );

      await FirebaseService().saveMealLog(mealLog, userId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal saved successfully')),
      );

      // Pop twice to return to dashboard
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save meal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.analysisResults['items'] as List;
    final totalCalories = items.fold<double>(
      0,
      (sum, item) =>
          sum +
          (item['food'][0]['food_info']['nutrition']['calories_100g'] *
              item['food'][0]['food_info']['quantity'] /
              100),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: Column(
        children: [
          // Image preview
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),

          // Date, Time and Meal Type selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormat('MMM d, y').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _selectedTime.format(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _showMealTypeDialog,
              icon: const Icon(Icons.restaurant),
              label: Text(_selectedMealType),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),

          // Results list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total calories
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Total Calories',
                          style: AppTypography.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${totalCalories.round()} kcal',
                          style: AppTypography.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Detected items
                Text(
                  'Detected Items',
                  style: AppTypography.headlineLarge,
                ),
                const SizedBox(height: 8),
                ...items.map((item) => _FoodItemCard(item: item)),
              ],
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: 'Save to Log',
              onPressed: _saveMealLog,
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _FoodItemCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final foodInfo = item['food'][0]['food_info'];
    final nutrition = foodInfo['nutrition'];
    final ingredients = item['food'][0]['ingredients'] as List;
    final totalWeight = foodInfo['quantity'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food name and total weight
            Row(
              children: [
                Expanded(
                  child: Text(
                    foodInfo['display_name'] as String,
                    style: AppTypography.headlineMedium,
                  ),
                ),
                Text(
                  '${totalWeight.round()}g',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Main food macros
            Row(
              children: [
                _NutritionItem(
                  label: 'Calories',
                  value:
                      '${(nutrition['calories_100g'] * totalWeight / 100).round()}',
                  unit: 'kcal',
                ),
                _NutritionItem(
                  label: 'Protein',
                  value: (nutrition['proteins_100g'] * totalWeight / 100)
                      .toStringAsFixed(1),
                  unit: 'g',
                ),
                _NutritionItem(
                  label: 'Carbs',
                  value: (nutrition['carbs_100g'] * totalWeight / 100)
                      .toStringAsFixed(1),
                  unit: 'g',
                ),
                _NutritionItem(
                  label: 'Fat',
                  value: (nutrition['fat_100g'] * totalWeight / 100)
                      .toStringAsFixed(1),
                  unit: 'g',
                ),
              ],
            ),

            if (ingredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Ingredients section
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    'Ingredients',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  children: ingredients.map((ingredient) {
                    final ingredientInfo = ingredient['food_info'];
                    final quantity = ingredient['quantity'] as double;
                    final ingredientNutrition = ingredientInfo['nutrition'];
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ingredient name, weight and grade
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ingredientInfo['display_name'] as String,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${quantity.round()}g',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getGradeColor(
                                      ingredientInfo['fv_grade'] as String),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ingredientInfo['fv_grade'] as String,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Ingredient nutrition info
                          Row(
                            children: [
                              _NutritionItem(
                                label: 'Calories',
                                value:
                                    '${(ingredientNutrition['calories_100g'] * quantity / 100).round()}',
                                unit: 'kcal',
                                small: true,
                              ),
                              _NutritionItem(
                                label: 'Protein',
                                value: (ingredientNutrition['proteins_100g'] *
                                        quantity /
                                        100)
                                    .toStringAsFixed(1),
                                unit: 'g',
                                small: true,
                              ),
                              _NutritionItem(
                                label: 'Carbs',
                                value: (ingredientNutrition['carbs_100g'] *
                                        quantity /
                                        100)
                                    .toStringAsFixed(1),
                                unit: 'g',
                                small: true,
                              ),
                              _NutritionItem(
                                label: 'Fat',
                                value: (ingredientNutrition['fat_100g'] *
                                        quantity /
                                        100)
                                    .toStringAsFixed(1),
                                unit: 'g',
                                small: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool small;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.unit,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: (small ? AppTypography.bodySmall : AppTypography.bodyMedium)
                .copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value$unit',
            style: (small ? AppTypography.bodySmall : AppTypography.bodyMedium)
                .copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
