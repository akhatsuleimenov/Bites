// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/core/widgets/cards.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/screens/food_logging/widgets/ingredients_editor.dart';

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

  void _updateValue(String field, double value,
      [int? ingredientIndex, String? textValue]) {
    setState(() {
      Ingredient target = ingredientIndex != null
          ? _mealLog.foodInfo.ingredients[ingredientIndex]
          : _mealLog.foodInfo.mainItem;

      if (field == 'title' && textValue != null) {
        // Handle title update
        target.title = textValue;
        return;
      }

      if (field == 'grams') {
        // Calculate ratio for scaling
        double ratio = value / target.grams;
        target.grams = value;
        target.nutritionData.calories *= ratio;
        target.nutritionData.protein *= ratio;
        target.nutritionData.carbs *= ratio;
        target.nutritionData.fats *= ratio;
      } else {
        switch (field) {
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
      }

      // Update main item totals if this was an ingredient change
      if (ingredientIndex != null) {
        _updateMainItemTotals();
      }
    });
  }

  void _updateMainItemTotals() {
    var mainItem = _mealLog.foodInfo.mainItem;
    var ingredients = _mealLog.foodInfo.ingredients;

    // Reset main item values
    mainItem.grams = 0;
    mainItem.nutritionData.calories = 0;
    mainItem.nutritionData.protein = 0;
    mainItem.nutritionData.carbs = 0;
    mainItem.nutritionData.fats = 0;

    // Sum up all ingredients
    for (var ingredient in ingredients) {
      mainItem.grams += ingredient.grams;
      mainItem.nutritionData.calories += ingredient.nutritionData.calories;
      mainItem.nutritionData.protein += ingredient.nutritionData.protein;
      mainItem.nutritionData.carbs += ingredient.nutritionData.carbs;
      mainItem.nutritionData.fats += ingredient.nutritionData.fats;
    }
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
        await appController.saveMealLog(_mealLog, _mealLog.userId);
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
      print("error: $e");

      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Failed to update meal. Try again later'
              : 'Failed to save meal. Try again later'),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Nutrition', style: TypographyStyles.h3()),
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Image preview
                  if (_mealLog.imagePath.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                    ),

                  // Date, Time and Meal Type selector
                  const SizedBox(height: 16),

                  // Results list
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mealLog.foodInfo.mainItem.title,
                          style: TypographyStyles.h3(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  iconColor: AppColors.textPrimary,
                                  foregroundColor: AppColors.textPrimary,
                                  backgroundColor: AppColors.cardBackground,
                                  side: BorderSide(
                                    color: AppColors.textPrimary,
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
                                  iconColor: AppColors.textPrimary,
                                  foregroundColor: AppColors.textPrimary,
                                  backgroundColor: AppColors.cardBackground,
                                  side: BorderSide(
                                    color: AppColors.textPrimary,
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
                        _FoodItemCard(
                          item: _mealLog.foodInfo,
                          onValueChanged: _updateValue,
                          onIngredientChanged: (index, field, value,
                                  [textValue]) =>
                              _updateValue(field, value, index, textValue),
                          showIngredients: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: PrimaryButton(
              onPressed: _saveMealLog,
              loading: _isSaving,
              text: _isEditing ? 'Update Meal' : 'Save to Log',
              textColor: AppColors.textPrimary,
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
  final Function(int index, String field, double value, [String? textValue])
      onIngredientChanged;

  const _FoodItemCard({
    required this.item,
    required this.onValueChanged,
    this.showIngredients = false,
    required this.onIngredientChanged,
  });

  @override
  State<_FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<_FoodItemCard> {
  late Map<String, TextEditingController> controllers;
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    Ingredient ingredientInfo =
        widget.showIngredients ? widget.item.mainItem : widget.item;

    // Initialize focus nodes
    ['grams', 'calories', 'protein', 'carbs', 'fat'].forEach((field) {
      _focusNodes[field] = FocusNode();
    });

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

    // Add focus listeners to update on focus loss
    _focusNodes.forEach((field, node) {
      node.addListener(() {
        if (!node.hasFocus) {
          _updateFieldValue(field);
        }
      });
    });
  }

  void _updateFieldValue(String field) {
    final value = double.tryParse(controllers[field]!.text);
    if (value != null) {
      widget.onValueChanged(field, value);
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FoodItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update controllers that don't have focus
    Ingredient ingredientInfo =
        widget.showIngredients ? widget.item.mainItem : widget.item;
    controllers.forEach((field, controller) {
      if (!_focusNodes[field]!.hasFocus) {
        double value;
        switch (field) {
          case 'grams':
            value = ingredientInfo.grams;
            break;
          case 'calories':
            value = ingredientInfo.nutritionData.calories;
            break;
          case 'protein':
            value = ingredientInfo.nutritionData.protein;
            break;
          case 'carbs':
            value = ingredientInfo.nutritionData.carbs;
            break;
          case 'fat':
            value = ingredientInfo.nutritionData.fats;
            break;
          default:
            return;
        }
        controller.text = value.toStringAsFixed(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardBackground.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Macros',
                  style: TypographyStyles.h4Bold(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMacroItem(
                      'Calories',
                      controllers['calories']!.text,
                      'kcal',
                      AppColors.calories,
                      Icons.local_fire_department_rounded,
                    ),
                    _buildMacroItem(
                      'Carbs',
                      controllers['carbs']!.text,
                      'g',
                      AppColors.carbs,
                      Icons.grass_rounded,
                    ),
                    _buildMacroItem(
                      'Fat',
                      controllers['fat']!.text,
                      'g',
                      AppColors.fat,
                      Icons.circle,
                    ),
                    _buildMacroItem(
                      'Protein',
                      controllers['protein']!.text,
                      'g',
                      AppColors.protein,
                      Icons.egg_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.showIngredients && widget.item is FoodInfo) ...[
            const SizedBox(height: 16),
            IngredientsEditor(
              foodInfo: widget.item,
              onIngredientChanged: widget.onIngredientChanged,
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
              style: TypographyStyles.bodyMedium(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
          ],
          TextField(
            controller: controllers[field],
            focusNode: _focusNodes[field],
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
            onSubmitted: (_) => _updateFieldValue(field),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TypographyStyles.subtitle(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TypographyStyles.bodyBold(
                color: color,
              ),
            ),
            const SizedBox(width: 1),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                unit,
                style: TypographyStyles.subtitle(
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
