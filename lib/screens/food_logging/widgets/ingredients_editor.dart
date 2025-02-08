// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/widgets/cards.dart';

class IngredientsEditor extends StatefulWidget {
  final FoodInfo foodInfo;
  final Function(int index, String field, double value, [String? textValue])
      onIngredientChanged;

  const IngredientsEditor({
    super.key,
    required this.foodInfo,
    required this.onIngredientChanged,
  });

  @override
  State<IngredientsEditor> createState() => _IngredientsEditorState();
}

class _IngredientsEditorState extends State<IngredientsEditor> {
  // Add controllers as class fields
  late List<TextEditingController> _nameControllers;
  late List<double> _gramValues;
  late List<bool> _isEditingGrams;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameControllers = widget.foodInfo.ingredients
        .map((i) => TextEditingController(text: i.title))
        .toList();
    _gramValues = widget.foodInfo.ingredients.map((i) => i.grams).toList();
    _isEditingGrams =
        List.generate(widget.foodInfo.ingredients.length, (_) => false);
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showEditSheet() {
    final ScrollController scrollController = ScrollController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: (MediaQuery.of(context).size.height -
                    MediaQuery.of(context).viewInsets.bottom) *
                0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Edit ingredients',
                        style: TypographyStyles.h4Bold(),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: widget.foodInfo.ingredients.length + 1,
                    separatorBuilder: (_, __) => const Divider(
                      height: 16,
                      color: AppColors.inputBorder,
                    ),
                    itemBuilder: (context, index) {
                      if (index == widget.foodInfo.ingredients.length) {
                        // return _buildNewIngredientField();
                        return const SizedBox.shrink();
                      }
                      return _buildEditableIngredient(
                        index,
                        setSheetState,
                      );
                    },
                  ),
                ),

                // Action buttons - now in a container with background
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 48,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel',
                              style: TypographyStyles.bodyMedium()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // Validate all ingredients
                            bool isValid = true;
                            for (var i = 0;
                                i < widget.foodInfo.ingredients.length;
                                i++) {
                              if (_gramValues[i] <= 0 ||
                                  _nameControllers[i].text.trim().isEmpty) {
                                isValid = false;
                                break;
                              }
                            }

                            if (!isValid) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please fill in all required fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Save logic stays the same
                            setState(() {
                              for (var i = 0;
                                  i < widget.foodInfo.ingredients.length;
                                  i++) {
                                widget.onIngredientChanged(
                                    i, 'grams', _gramValues[i]);
                                if (_nameControllers[i].text !=
                                    widget.foodInfo.ingredients[i].title) {
                                  widget.onIngredientChanged(
                                    i,
                                    'title',
                                    double.nan,
                                    _nameControllers[i].text,
                                  );
                                }
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Save',
                              style: TypographyStyles.bodyMedium()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableIngredient(int index, StateSetter setSheetState) {
    final bool isGramsValid = _gramValues[index] > 0;
    final bool isNameValid = _nameControllers[index].text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
            padding: EdgeInsets.zero,
            onPressed: () {
              // Remove ingredient logic
            },
            icon:
                const Icon(Icons.remove_circle_outline, color: AppColors.error),
          ),
          Expanded(
            child: TextField(
              controller: _nameControllers[index],
              style: TypographyStyles.bodyBold(),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                errorText: !isNameValid ? 'Required' : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isEditingGrams[index])
                IconButton(
                  onPressed: () {
                    setSheetState(() {
                      _gramValues[index] =
                          (_gramValues[index] - 10).clamp(1, double.infinity);
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              GestureDetector(
                onTap: () => setSheetState(
                    () => _isEditingGrams[index] = !_isEditingGrams[index]),
                child: Container(
                  width: 60,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        !isGramsValid ? Border.all(color: Colors.red) : null,
                  ),
                  child: _isEditingGrams[index]
                      ? SizedBox(
                          width: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            autofocus: true,
                            maxLength: 3,
                            controller: TextEditingController(
                                text: _gramValues[index].toStringAsFixed(0)),
                            style: TypographyStyles.bodyMedium(),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              suffixText: 'g',
                              counterText: '', // Hides the character counter
                            ),
                            onSubmitted: (value) {
                              final newValue = int.tryParse(value);
                              if (newValue != null && newValue > 0) {
                                setSheetState(() {
                                  _gramValues[index] = newValue.toDouble();
                                  _isEditingGrams[index] = false;
                                });
                              }
                            },
                          ),
                        )
                      : Text(
                          '${_gramValues[index].toStringAsFixed(0)}g',
                          style: TypographyStyles.bodyMedium(),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
              if (_isEditingGrams[index])
                IconButton(
                  onPressed: () {
                    setSheetState(() {
                      _gramValues[index] += 10;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewIngredientField() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'New ingredient',
                hintStyle: TypographyStyles.bodyMedium(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header with info icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Ingredients',
                style: TypographyStyles.h4Bold(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ingredients list
          ...widget.foodInfo.ingredients.asMap().entries.map((entry) {
            final ingredient = entry.value;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      ingredient.title,
                      style: TypographyStyles.bodyBold(),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${ingredient.grams.toStringAsFixed(0)}g',
                        style: TypographyStyles.bodyMedium(),
                      ),
                    ),
                  ],
                ),
                if (entry.key < widget.foodInfo.ingredients.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
              ],
            );
          }).toList(),

          // Edit button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(
                  color: AppColors.buttonBorder,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _showEditSheet,
              child: Text(
                'Edit',
                style: TypographyStyles.bodyMedium(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IngredientCard extends StatefulWidget {
  final Ingredient ingredient;
  final Function(String field, double value) onValueChanged;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onValueChanged,
  });

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  late Map<String, TextEditingController> controllers;
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize focus nodes
    ['grams', 'calories', 'protein', 'carbs', 'fat'].forEach((field) {
      _focusNodes[field] = FocusNode();
    });

    controllers = {
      'grams': TextEditingController(
        text: widget.ingredient.grams.toStringAsFixed(1),
      ),
      'calories': TextEditingController(
        text: widget.ingredient.nutritionData.calories.toStringAsFixed(1),
      ),
      'protein': TextEditingController(
        text: widget.ingredient.nutritionData.protein.toStringAsFixed(1),
      ),
      'carbs': TextEditingController(
        text: widget.ingredient.nutritionData.carbs.toStringAsFixed(1),
      ),
      'fat': TextEditingController(
        text: widget.ingredient.nutritionData.fats.toStringAsFixed(1),
      ),
    };

    // Add focus listeners
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
    controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((node) => node.dispose());
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
                  widget.ingredient.title,
                  style: TypographyStyles.h4(),
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
}
