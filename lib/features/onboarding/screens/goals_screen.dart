import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

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

  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'lose_weight',
      'title': 'Lose Weight',
      'subtitle': 'I want to reduce my body weight',
      'icon': Icons.trending_down,
      'calorieAdjustment': -500, // 500 calorie deficit
    },
    {
      'id': 'maintain',
      'title': 'Maintain Weight',
      'subtitle': 'I\'m happy with my current weight',
      'icon': Icons.balance,
      'calorieAdjustment': 0,
    },
    {
      'id': 'gain_weight',
      'title': 'Gain Weight',
      'subtitle': 'I want to increase my body weight',
      'icon': Icons.trending_up,
      'calorieAdjustment': 500, // 500 calorie surplus
    },
    {
      'id': 'build_muscle',
      'title': 'Build Muscle',
      'subtitle': 'I want to gain muscle mass',
      'icon': Icons.fitness_center,
      'calorieAdjustment': 300, // Moderate surplus for muscle gain
    },
    {
      'id': 'improve_health',
      'title': 'Improve Health',
      'subtitle': 'I want to focus on better nutrition',
      'icon': Icons.favorite,
      'calorieAdjustment': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomBackButton(),
              const SizedBox(height: 32),
              Text(
                'What\'s your main goal?',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll customize your plan accordingly',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _goals.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final isSelected = _selectedGoal == goal['id'];

                    return _GoalCard(
                      title: goal['title'],
                      subtitle: goal['subtitle'],
                      icon: goal['icon'],
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedGoal = goal['id'];
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  if (_selectedGoal != null) {
                    final selectedGoal = _goals.firstWhere(
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
                      '/onboarding/notifications',
                      arguments: updatedUserData,
                    );
                  }
                },
                enabled: _selectedGoal != null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateBMR(Map<String, dynamic> userData) {
    // Mifflin-St Jeor Equation
    final double weight = userData['weight'] as double;
    final double height = userData['height'] as double;
    final int age = userData['age'] as int;
    final String gender = userData['gender'] as String;

    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    if (gender == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    return bmr;
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: isSelected ? Colors.white : Colors.transparent,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
