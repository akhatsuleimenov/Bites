// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/core/widgets/buttons.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _portionController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  MealType _selectedMealType = MealType.lunch;

  // Add the dialog method
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
                MealType.values.length,
                (index) => ListTile(
                  title: Text(MealType.values[index].name),
                  trailing: _selectedMealType == MealType.values[index]
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () {
                    setState(() => _selectedMealType = MealType.values[index]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
        leading: const CustomBackButton(),
        backgroundColor: AppColors.cardBackground,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Food Name Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Food Details',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      prefixIcon: const Icon(Icons.restaurant_menu),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelStyle: const TextStyle(color: AppColors.textPrimary),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textPrimary),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a food name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _showMealTypeDialog,
                    icon: const Icon(Icons.schedule),
                    label: Text(_selectedMealType.name),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.cardBackground,
                      side: BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Portion Size Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portion Size',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _portionController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            suffixText: 'g',
                            prefixIcon: const Icon(Icons.scale),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle:
                                const TextStyle(color: AppColors.textPrimary),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.textPrimary),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          validator: (value) => _validateNumber(value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _adjustPortion(-10),
                            ),
                            Text(
                              '10',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _adjustPortion(10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nutrition Facts Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition Facts',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionField(
                    controller: _caloriesController,
                    label: 'Calories',
                    suffix: 'kcal',
                    icon: Icons.local_fire_department,
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionField(
                    controller: _proteinController,
                    label: 'Protein',
                    suffix: 'g',
                    icon: Icons.egg_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionField(
                    controller: _carbsController,
                    label: 'Carbs',
                    suffix: 'g',
                    icon: Icons.grain,
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionField(
                    controller: _fatController,
                    label: 'Fat',
                    suffix: 'g',
                    icon: Icons.cookie_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Save to Log',
              onPressed: _saveEntry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNutritionField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textPrimary),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: (value) => _validateNumber(value),
    );
  }

  String? _validateNumber(String? value) {
    if (value?.isEmpty ?? true) return 'Required';
    if (double.tryParse(value!) == null) return 'Invalid number';
    return null;
  }

  void _adjustPortion(int amount) {
    final current = int.tryParse(_portionController.text) ?? 100;
    if (current + amount > 0) {
      setState(() {
        _portionController.text = (current + amount).toString();
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final quantity = double.parse(_portionController.text);
      final calories = double.parse(_caloriesController.text);
      final protein = double.parse(_proteinController.text);
      final carbs = double.parse(_carbsController.text);
      final fat = double.parse(_fatController.text);
      print("userid: $userId");
      final foodInfo = FoodInfo(
        nutritionalInfo: NutritionalInfo(
          grade: 'N/A', // Manual entries don't have grades
          name: _nameController.text,
          quantity: quantity,
          nutritionData: NutritionData(
            calories: calories,
            carbs: carbs,
            fats: fat,
            protein: protein,
          ),
        ),
        ingredients: [], // Manual entries don't have ingredients
      );
      print("Food info $foodInfo");

      final mealLog = MealLog(
        userId: userId,
        dateTime: DateTime.now(),
        mealType: _selectedMealType.name,
        imagePath: '', // Manual entries don't have images
        analysisId: 'manual_entry_${DateTime.now().millisecondsSinceEpoch}',
        foodInfo: foodInfo,
      );
      print("$mealLog");

      await FirebaseService().saveMealLog(mealLog, userId);
      print("Saved");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal saved successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save meal: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _portionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }
}
