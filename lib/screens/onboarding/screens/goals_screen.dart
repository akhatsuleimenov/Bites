// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/fitness_goals_data.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';

class GoalsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const GoalsScreen({
    super.key,
    required this.userData,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String? _selectedGoal;

  double _calculateBMR(Map<String, dynamic> userData) {
    // Mifflin-St Jeor Equation
    final double weight = userData['weight'];
    final int height = userData['height'];
    final int age = userData['age'];
    final String gender = userData['gender'];

    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    if (gender == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    return bmr;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      currentStep: 7,
      totalSteps: 8,
      title: 'What\'s your main goal?',
      subtitle:
          'Whether you want to lose weight, maintain it, or gain muscle, understanding your goal allows us to design the right plan for you.',
      enableContinue: _selectedGoal != null,
      onContinue: () {
        if (_selectedGoal != null) {
          final selectedGoal = goals.firstWhere(
            (g) => g['id'] == _selectedGoal,
          );

          final updatedUserData = {
            ...widget.userData,
            'goal': _selectedGoal,
            'calorieAdjustment': selectedGoal['calorieAdjustment'],
          };

          // Calculate TDEE and adjusted calories here
          final double bmr = _calculateBMR(updatedUserData);
          final double tdee =
              bmr * (updatedUserData['activityMultiplier'] as double);
          final int adjustedCalories =
              (tdee + selectedGoal['calorieAdjustment']).round();

          updatedUserData['bmr'] = bmr;
          updatedUserData['tdee'] = tdee;
          updatedUserData['dailyCalories'] = adjustedCalories;

          Navigator.pushNamed(
            context,
            '/onboarding/goal-speed',
            arguments: updatedUserData,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 56,
        ),
        child: Column(
          children: goals.map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ChoiceButton(
                icon: goal['icon'],
                onPressed: () => setState(() {
                  _selectedGoal = goal['id'];
                }),
                text: goal['title'],
                subtitle: goal['subtitle'],
                pressed: _selectedGoal == goal['id'],
                displayCheck: true,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
