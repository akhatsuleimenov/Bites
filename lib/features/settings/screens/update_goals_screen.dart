import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/features/settings/controllers/settings_controller.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';
import 'package:provider/provider.dart';

class UpdateGoalsScreen extends StatelessWidget {
  const UpdateGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsController()..loadUserData(),
      child: const UpdateGoalsScreenContent(),
    );
  }
}

class UpdateGoalsScreenContent extends StatefulWidget {
  const UpdateGoalsScreenContent({super.key});

  @override
  State<UpdateGoalsScreenContent> createState() => _UpdateGoalsScreenState();
}

class _UpdateGoalsScreenState extends State<UpdateGoalsScreenContent> {
  String? _selectedGoal;
  late double _targetWeight;
  String? _workoutFrequency;
  late FixedExtentScrollController _weightController;

  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'lose_weight',
      'title': 'Lose Weight',
      'subtitle': 'I want to reduce my body weight',
      'icon': Icons.trending_down,
      'calorieAdjustment': -500,
    },
    {
      'id': 'maintain',
      'title': 'Maintain Weight',
      'subtitle': 'I\'m happy with my current weight',
      'icon': Icons.balance,
      'calorieAdjustment': 0,
    },
    {
      'id': 'lean_bulk',
      'title': 'Lean Bulk',
      'subtitle': 'I want to gain muscle mass without gaining fat',
      'icon': Icons.fitness_center,
      'calorieAdjustment': 300,
    },
    {
      'id': 'gain_weight',
      'title': 'Gain Weight',
      'subtitle': 'I want to increase my body weight',
      'icon': Icons.trending_up,
      'calorieAdjustment': 500,
    },
  ];

  final List<Map<String, dynamic>> _frequencies = [
    {
      'id': 'sedentary',
      'title': 'Sedentary',
      'subtitle': 'Little to no exercise',
      'icon': Icons.weekend,
      'multiplier': 1.2,
    },
    {
      'id': 'light',
      'title': '1-2 times a week',
      'subtitle': 'Light exercise',
      'icon': Icons.directions_walk,
      'multiplier': 1.375,
    },
    {
      'id': 'moderate',
      'title': '3-5 times a week',
      'subtitle': 'Moderate exercise',
      'icon': Icons.directions_run,
      'multiplier': 1.55,
    },
    {
      'id': 'active',
      'title': '6-7 times a week',
      'subtitle': 'Very active',
      'icon': Icons.fitness_center,
      'multiplier': 1.725,
    },
    {
      'id': 'athlete',
      'title': 'Athlete',
      'subtitle': 'Professional/Intense training',
      'icon': Icons.sports_gymnastics,
      'multiplier': 1.9,
    },
  ];

  @override
  void initState() {
    super.initState();
    _targetWeight = 70.0;
    _initializeControllers();
  }

  void _initializeControllers() {
    _weightController = FixedExtentScrollController(
      initialItem: _targetWeight.toInt() - 30,
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, _) {
        final userData = controller.userData;

        if (userData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Initialize values from userData only once
        if (_selectedGoal == null) {
          _selectedGoal = userData['goal'] ?? 'maintain_weight';
          _workoutFrequency = userData['workoutFrequency'] ?? 'moderate';
          _targetWeight = userData['targetWeight']?.toDouble() ?? 70.0;
          _weightController.jumpToItem(_targetWeight.toInt() - 30);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Update Goals'),
            leading: const CustomBackButton(),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('What\'s your main goal?',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              ...List.generate(_goals.length, (index) {
                final goal = _goals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _GoalCard(
                    title: goal['title'],
                    subtitle: goal['subtitle'],
                    icon: goal['icon'],
                    isSelected: _selectedGoal == goal['id'],
                    onTap: () => setState(() => _selectedGoal = goal['id']),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text('How often do you work out?',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              ...List.generate(_frequencies.length, (index) {
                final frequency = _frequencies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _FrequencyCard(
                    title: frequency['title'],
                    subtitle: frequency['subtitle'],
                    icon: frequency['icon'],
                    isSelected: _workoutFrequency == frequency['id'],
                    onTap: () =>
                        setState(() => _workoutFrequency = frequency['id']),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text('Target Weight (kg)', style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      _targetWeight = (value + 30).toDouble();
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final value = index + 30;
                      return Center(
                        child: Text(
                          '$value kg',
                          style: AppTypography.bodyLarge,
                        ),
                      );
                    },
                    childCount: 171,
                  ),
                  controller: _weightController,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.005,
                  diameterRatio: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Save Changes',
                onPressed: _saveChanges,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    try {
      await context.read<SettingsController>().updateProfile({
        'goal': _selectedGoal!,
        'targetWeight': _targetWeight,
        'workoutFrequency': _workoutFrequency!,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update goals: $e')),
      );
    }
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => onTap(),
        ),
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => onTap(),
        ),
      ),
    );
  }
}
