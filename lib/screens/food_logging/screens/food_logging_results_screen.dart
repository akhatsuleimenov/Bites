// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/widgets/cards.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/core/widgets/buttons.dart';

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
  bool _isSaving = false;

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
    final quantity = foodItem['quantity'] as double;

    // Create ingredients list
    final ingredients =
        (foodItem['ingredients'] as List? ?? []).map((ingredient) {
      final ingredientInfo = ingredient['food_info'];
      final ingNutrition = ingredientInfo['nutrition'];
      final ingQuantity = ingredient['quantity'] as double;

      return NutritionalInfo(
        grade: ingredientInfo['fv_grade'],
        name: ingredientInfo['display_name'],
        quantity: ingQuantity,
        nutritionData: NutritionData(
          calories: ingNutrition['calories_100g'],
          carbs: ingNutrition['carbs_100g'],
          fats: ingNutrition['fat_100g'],
          protein: ingNutrition['proteins_100g'],
        ),
      );
    }).toList();

    final foodInfoObj = FoodInfo(
      nutritionalInfo: NutritionalInfo(
        grade: foodInfo['fv_grade'],
        name: foodInfo['display_name'],
        quantity: quantity,
        nutritionData: NutritionData(
          calories: nutrition['calories_100g'],
          carbs: nutrition['carbs_100g'],
          fats: nutrition['fat_100g'],
          protein: nutrition['proteins_100g'],
        ),
      ),
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

  void _updateValue(String field, double value, [int? ingredientIndex]) {
    setState(() {
      NutritionalInfo target = ingredientIndex != null
          ? _mealLog.foodInfo.ingredients[ingredientIndex]
          : _mealLog.foodInfo.nutritionalInfo;

      switch (field) {
        case 'quantity':
          target.quantity = value;
          break;
        case 'calories':
          target.nutritionData.calories = value;
          break;
        case 'protein':
          target.nutritionData.protein = value;
          break;
        case 'carbs':
          target.nutritionData.carbs = value;
          break;
        case 'fat':
          target.nutritionData.fats = value;
          break;
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
    if (_isSaving) return; // Prevent double-taps

    setState(() => _isSaving = true);

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

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save meal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: AppColors.cardBackground,
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
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.cardBackground,
                      side: BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
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
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.cardBackground,
                      side: BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
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
                backgroundColor: AppColors.cardBackground,
                side: BorderSide(
                  color: AppColors.primary,
                ),
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
                  onValueChanged: _updateValue,
                  onIngredientChanged: (index, field, value) =>
                      _updateValue(field, value, index),
                  showIngredients: true,
                ),
              ],
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              onPressed: _saveMealLog,
              loading: _isSaving,
              text: 'Save to Log',
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodItemCard extends StatefulWidget {
  final dynamic item;
  final Function(String field, double value) onValueChanged;
  final bool showIngredients;
  final Function(int index, String field, double value)? onIngredientChanged;

  const _FoodItemCard({
    required this.item,
    required this.onValueChanged,
    this.showIngredients = false,
    this.onIngredientChanged,
  });

  @override
  State<_FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<_FoodItemCard> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    NutritionalInfo nutritionalInfo = widget.showIngredients == true
        ? widget.item.nutritionalInfo
        : widget.item;
    controllers = {
      'quantity': TextEditingController(
          text: nutritionalInfo.quantity.toStringAsFixed(1)),
      'calories': TextEditingController(
          text: nutritionalInfo.nutritionData.calories.toStringAsFixed(1)),
      'protein': TextEditingController(
          text: nutritionalInfo.nutritionData.protein.toStringAsFixed(1)),
      'carbs': TextEditingController(
          text: nutritionalInfo.nutritionData.carbs.toStringAsFixed(1)),
      'fat': TextEditingController(
          text: nutritionalInfo.nutritionData.fats.toStringAsFixed(1)),
    };
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.showIngredients
                      ? widget.item.nutritionalInfo.name
                      : widget.item.name,
                  style: AppTypography.headlineSmall,
                ),
              ),
              _buildEditableField('quantity', 'g'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildEditableField('calories', 'kcal', label: 'Calories'),
              _buildEditableField('protein', 'g', label: 'Protein'),
              _buildEditableField('carbs', 'g', label: 'Carbs'),
              _buildEditableField('fat', 'g', label: 'Fat'),
            ],
          ),
          if (widget.showIngredients && widget.item is FoodInfo) ...[
            ExpansionTile(
              title: Text(
                'Ingredients',
                style: AppTypography.headlineSmall
                    .copyWith(color: Colors.grey[700]),
              ),
              children:
                  widget.item.ingredients.asMap().entries.map<Widget>((entry) {
                return _FoodItemCard(
                  item: entry.value,
                  onValueChanged: (field, value) =>
                      widget.onIngredientChanged?.call(entry.key, field, value),
                  showIngredients: false,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditableField(String field, String unit, {String? label}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (label != null) ...[
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
          ],
          TextField(
            controller: controllers[field],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              suffixText: unit,
              isDense: true,
              border: InputBorder.none,
              labelStyle: const TextStyle(color: AppColors.textPrimary),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textPrimary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            onChanged: (value) {
              final newValue = double.tryParse(value);
              if (newValue != null) {
                widget.onValueChanged(field, newValue);
              }
            },
          ),
        ],
      ),
    );
  }
}
