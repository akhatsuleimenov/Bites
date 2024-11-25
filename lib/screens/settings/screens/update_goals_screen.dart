// Flutter imports:
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/constants/fitness_goals_data.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/core/models/user_profile_model.dart';
import 'package:bites/core/widgets/buttons.dart';

class UpdateGoalsScreen extends StatelessWidget {
  const UpdateGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) => const UpdateGoalsScreenContent(),
    );
  }
}

class UpdateGoalsScreenContent extends StatefulWidget {
  const UpdateGoalsScreenContent({super.key});

  @override
  State<UpdateGoalsScreenContent> createState() => _UpdateGoalsScreenState();
}

class _UpdateGoalsScreenState extends State<UpdateGoalsScreenContent> {
  late UserProfile _profile;
  late FixedExtentScrollController _weightController;

  @override
  void initState() {
    super.initState();
    _profile = UserProfile();
    _weightController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        // Initialize values from userData only once
        if (_profile.isEmpty()) {
          _profile = controller.userProfile;
          _weightController = FixedExtentScrollController(
              initialItem: MeasurementHelper.convertWeight(
                      _profile.targetWeight, _profile.isMetric)
                  .toInt());
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
              ...List.generate(goals.length, (index) {
                final goal = goals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _GoalCard(
                    title: goal['title'],
                    subtitle: goal['subtitle'],
                    icon: goal['icon'],
                    isSelected: _profile.goal == goal['id'],
                    onTap: () => setState(() => _profile.goal = goal['id']),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text('How often do you work out?',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              ...List.generate(frequencies.length, (index) {
                final frequency = frequencies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _FrequencyCard(
                    title: frequency['title'],
                    subtitle: frequency['subtitle'],
                    icon: frequency['icon'],
                    isSelected: _profile.workoutFrequency == frequency['id'],
                    onTap: () => setState(
                        () => _profile.workoutFrequency = frequency['id']),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text(
                  'Target Weight (${MeasurementHelper.getWeightLabel(_profile.isMetric)})',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      _profile.targetWeight =
                          MeasurementHelper.standardizeWeight(
                              value.toDouble(), _profile.isMetric);
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          MeasurementHelper.formatWeight(
                              index.toDouble(), _profile.isMetric),
                          style: AppTypography.bodyLarge,
                        ),
                      );
                    },
                    childCount: MeasurementHelper.childCountWeightPicker(
                        _profile.isMetric),
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
      await context.read<AppController>().updateProfile({
        'goal': _profile.goal,
        'targetWeight': _profile.targetWeight,
        'workoutFrequency': _profile.workoutFrequency,
        'calorieAdjustment': goals
            .firstWhere((g) => g['id'] == _profile.goal)['calorieAdjustment'],
        'activityMultiplier': frequencies.firstWhere(
            (f) => f['id'] == _profile.workoutFrequency)['multiplier'],
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
