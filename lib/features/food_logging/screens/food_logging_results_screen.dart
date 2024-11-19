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
  late MealLog _mealLog;

  final List<String> _mealTypes = [
    'Breakfast',
    'Morning Snack',
    'Lunch',
    'Afternoon Snack',
    'Dinner',
    'Evening Snack',
  ];

  @override
  void initState() {
    super.initState();
    // Convert analysis results to MealLog immediately
    final foodItem = widget.analysisResults['items'][0]['food'][0];
    final foodInfo = foodItem['food_info'];
    final nutrition = foodInfo['nutrition'];
    final quantity = foodInfo['quantity'] as double;

    // Create ingredients list
    final ingredients =
        (foodItem['ingredients'] as List? ?? []).map((ingredient) {
      final ingredientInfo = ingredient['food_info'];
      final ingNutrition = ingredientInfo['nutrition'];
      final ingQuantity = ingredient['quantity'] as double;

      return Ingredient(
        grade: ingredientInfo['fv_grade'],
        name: ingredientInfo['display_name'],
        quantity: ingQuantity,
        calories: ingNutrition['calories_100g'],
        carbs: ingNutrition['carbs_100g'],
        fat: ingNutrition['fat_100g'],
        protein: ingNutrition['proteins_100g'],
      );
    }).toList();

    final foodInfoObj = FoodInfo(
      grade: foodInfo['fv_grade'],
      name: foodInfo['display_name'],
      quantity: quantity,
      calories: nutrition['calories_100g'],
      carbs: nutrition['carbs_100g'],
      fat: nutrition['fat_100g'],
      protein: nutrition['proteins_100g'],
      ingredients: ingredients,
    );

    _mealLog = MealLog(
      userId: FirebaseAuth.instance.currentUser!.uid,
      dateTime: DateTime.now(),
      mealType: _selectedMealType,
      imagePath: widget.imagePath,
      analysisId: widget.analysisResults['analysis_id'],
      foodInfo: foodInfoObj,
    );
  }

  void _updateQuantity(double newQuantity) {
    setState(() {
      _mealLog.foodInfo.quantity = newQuantity;
    });
  }

  void _updateCalories(double newCalories) {
    setState(() {
      _mealLog.foodInfo.calories = newCalories;
    });
  }

  void _updateIngredient(int index, {double? quantity, double? calories}) {
    setState(() {
      if (quantity != null) {
        _mealLog.foodInfo.ingredients[index].quantity = quantity;
      }
      if (calories != null) {
        _mealLog.foodInfo.ingredients[index].calories = calories;
      }
    });
  }

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
      final DateTime combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      _mealLog.dateTime = combinedDateTime;
      _mealLog.mealType = _selectedMealType;

      await FirebaseService().saveMealLog(_mealLog, _mealLog.userId);
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
              File(_mealLog.imagePath),
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
                // Meal information
                Text(
                  'Meal Information',
                  style: AppTypography.headlineLarge,
                ),
                const SizedBox(height: 8),
                _FoodItemCard(
                  item: _mealLog.foodInfo,
                  onQuantityChanged: _updateQuantity,
                  onCaloriesChanged: _updateCalories,
                  onIngredientChanged: _updateIngredient,
                  showIngredients: true,
                ),
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

class _FoodItemCard extends StatefulWidget {
  final dynamic item; // Can be FoodInfo or Ingredient
  final Function(double) onQuantityChanged;
  final Function(double) onCaloriesChanged;
  final bool showIngredients;
  final Function(int, {double? quantity, double? calories})?
      onIngredientChanged;

  const _FoodItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onCaloriesChanged,
    this.showIngredients = false,
    this.onIngredientChanged,
  });

  @override
  State<_FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<_FoodItemCard> {
  // Add controllers for all editable fields
  late TextEditingController weightController;
  late TextEditingController caloriesController;
  late TextEditingController proteinController;
  late TextEditingController carbsController;
  late TextEditingController fatController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    weightController =
        TextEditingController(text: widget.item.quantity.toStringAsFixed(1));
    caloriesController =
        TextEditingController(text: widget.item.calories.toStringAsFixed(1));
    proteinController =
        TextEditingController(text: widget.item.protein.toStringAsFixed(1));
    carbsController =
        TextEditingController(text: widget.item.carbs.toStringAsFixed(1));
    fatController =
        TextEditingController(text: widget.item.fat.toStringAsFixed(1));
  }

  @override
  void dispose() {
    weightController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    super.dispose();
  }

  // Add this method to access controllers
  Controllers getControllers() {
    return Controllers(
      weightController: weightController,
      caloriesController: caloriesController,
      proteinController: proteinController,
      carbsController: carbsController,
      fatController: fatController,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    widget.item.name,
                    style: AppTypography.headlineMedium,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      suffixText: 'g',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (value) {
                      final newValue = double.tryParse(value);
                      if (newValue != null) {
                        widget.onQuantityChanged(newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Macros row
            Row(
              children: [
                _EditableNutritionItem(
                  label: 'Calories',
                  controller: caloriesController,
                  unit: 'cal',
                  onChanged: (value) {
                    final newValue = double.tryParse(value);
                    if (newValue != null) {
                      widget.onCaloriesChanged(newValue);
                    }
                  },
                ),
                _EditableNutritionItem(
                  label: 'Protein',
                  controller: proteinController,
                  unit: 'g',
                ),
                _EditableNutritionItem(
                  label: 'Carbs',
                  controller: carbsController,
                  unit: 'g',
                ),
                _EditableNutritionItem(
                  label: 'Fat',
                  controller: fatController,
                  unit: 'g',
                ),
              ],
            ),

            // Ingredients section (only for main food item)
            if (widget.showIngredients && widget.item is FoodInfo) ...[
              const SizedBox(height: 12),
              const Divider(),
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
                  children: widget.item.ingredients
                      .asMap()
                      .entries
                      .map<Widget>((entry) {
                    final index = entry.key;
                    final ingredient = entry.value;
                    return _FoodItemCard(
                      item: ingredient,
                      onQuantityChanged: (quantity) => widget
                          .onIngredientChanged
                          ?.call(index, quantity: quantity),
                      onCaloriesChanged: (calories) => widget
                          .onIngredientChanged
                          ?.call(index, calories: calories),
                      showIngredients: false,
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
}

class _EditableNutritionItem extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String unit;
  final Function(String)? onChanged;

  const _EditableNutritionItem({
    required this.label,
    required this.controller,
    required this.unit,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            onChanged: onChanged,
            style:
                AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              suffixText: unit,
              isDense: true,
              border: InputBorder.none, // Removes underline
              enabledBorder: InputBorder.none, // Removes underline when enabled
              focusedBorder: InputBorder.none, // Removes underline when focused
            ),
          ),
        ],
      ),
    );
  }
}

// Add this class to hold controllers
class Controllers {
  final TextEditingController weightController;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;

  Controllers({
    required this.weightController,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
  });
}
