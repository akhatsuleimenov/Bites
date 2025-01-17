// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/core/widgets/cards.dart';
import 'package:bites/core/controllers/app_controller.dart';

class FoodLoggingResultsScreen extends StatefulWidget {
  final String? imagePath;
  final FoodInfo? resultFoodInfo;
  final MealLog? existingMealLog;

  const FoodLoggingResultsScreen({
    super.key,
    this.imagePath,
    this.resultFoodInfo,
    this.existingMealLog,
  }) : assert(
          (imagePath != null && resultFoodInfo != null) ||
              existingMealLog != null,
          'Either provide imagePath and resultFoodInfo for new log, or existingMealLog for editing',
        );

  @override
  State<FoodLoggingResultsScreen> createState() =>
      _FoodLoggingResultsScreenState();
}

class _FoodLoggingResultsScreenState extends State<FoodLoggingResultsScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late MealLog _mealLog;
  bool _isSaving = false;
  bool get _isEditing => widget.existingMealLog != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _mealLog = widget.existingMealLog!;
      _selectedDate = _mealLog.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(_mealLog.dateTime);
    } else {
      _mealLog = MealLog(
        userId: FirebaseAuth.instance.currentUser!.uid,
        dateTime: DateTime.now(),
        imagePath: widget.imagePath!,
        foodInfo: widget.resultFoodInfo!,
      );
    }
  }

  void _updateValue(String field, double value, [int? ingredientIndex]) {
    setState(() {
      Ingredient target = ingredientIndex != null
          ? _mealLog.foodInfo.ingredients[ingredientIndex]
          : _mealLog.foodInfo.mainItem;

      switch (field) {
        case 'grams':
          target.grams = value;
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

      final appController = Provider.of<AppController>(context, listen: false);
      if (_isEditing) {
        await appController.updateMealLog(_mealLog);
      } else {
        await FirebaseService().saveMealLog(_mealLog, _mealLog.userId);
      }

      if (!mounted) return;

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Meal updated successfully'
              : 'Meal saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Failed to update meal: $e'
              : 'Failed to save meal: $e'),
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
        title: Text(_isEditing ? 'Edit Meal' : 'Analysis Results'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            children: [
              // Image preview
              if (_mealLog.imagePath.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _mealLog.imagePath.startsWith('http')
                      ? Image.network(
                          _mealLog.imagePath,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
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

              // Results list
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  text: _isEditing ? 'Update Meal' : 'Save to Log',
                ),
              ),
            ],
          ),
        ),
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
    Ingredient ingredientInfo =
        widget.showIngredients ? widget.item.mainItem : widget.item;
    controllers = {
      'grams':
          TextEditingController(text: ingredientInfo.grams.toStringAsFixed(1)),
      'calories': TextEditingController(
          text: ingredientInfo.nutritionData.calories.toStringAsFixed(1)),
      'protein': TextEditingController(
          text: ingredientInfo.nutritionData.protein.toStringAsFixed(1)),
      'carbs': TextEditingController(
          text: ingredientInfo.nutritionData.carbs.toStringAsFixed(1)),
      'fat': TextEditingController(
          text: ingredientInfo.nutritionData.fats.toStringAsFixed(1)),
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
                      ? widget.item.mainItem.title
                      : widget.item.title,
                  style: AppTypography.headlineSmall,
                ),
              ),
              _buildEditableField('grams', 'g'),
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
