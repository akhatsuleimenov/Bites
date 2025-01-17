// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/constants/fitness_goals_data.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/core/models/user_profile_model.dart';
import 'package:bites/core/utils/measurement_utils.dart';
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
  late FixedExtentScrollController _kgController;
  late FixedExtentScrollController _lbController;

  @override
  void initState() {
    super.initState();
    _profile = UserProfile();
    _initializeControllers();
  }

  void _initializeControllers() {
    _kgController = FixedExtentScrollController(
      initialItem:
          (_profile.weight - MeasurementHelper.offsetWeightPicker(true))
              .toInt(),
    );

    final imperialWeight =
        MeasurementHelper.convertWeight(_profile.weight, false);

    _lbController = FixedExtentScrollController(
      initialItem:
          (imperialWeight - MeasurementHelper.offsetWeightPicker(false))
              .toInt(),
    );
  }

  @override
  void dispose() {
    _kgController.dispose();
    _lbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        _profile = controller.userProfile;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Update Goals'),
            leading: const CustomBackButton(),
            backgroundColor: AppColors.cardBackground,
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
              Text('Target Weight (kg)', style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: _profile.isMetric
                    ? _buildMetricWeightPicker()
                    : _buildImperialWeightPicker(),
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

  Widget _buildMetricWeightPicker() {
    return Row(
      children: [
        Expanded(
          child: _buildWheelScrollView(
            _kgController,
            MeasurementHelper.childCountWeightPicker(true),
            (value) {
              setState(() {
                _profile.targetWeight =
                    value + MeasurementHelper.offsetWeightPicker(true);
              });
            },
            MeasurementHelper.offsetWeightPicker(true).toInt(),
            'kg',
          ),
        ),
      ],
    );
  }

  Widget _buildImperialWeightPicker() {
    return Row(
      children: [
        Expanded(
          child: _buildWheelScrollView(
            _lbController,
            MeasurementHelper.childCountWeightPicker(false),
            (value) {
              setState(() {
                final lbs = value + MeasurementHelper.offsetWeightPicker(false);
                _profile.targetWeight = lbs * MeasurementHelper.lbToKg;
              });
            },
            MeasurementHelper.offsetWeightPicker(false).toInt(),
            'lb',
          ),
        ),
      ],
    );
  }

  Widget _buildWheelScrollView(
    FixedExtentScrollController controller,
    int childCount,
    Function(int) onSelectedItemChanged,
    int offset,
    String unit,
  ) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: childCount,
        builder: (context, index) {
          return Center(
            child: Text(
              '${index + offset} $unit',
              style: AppTypography.bodyLarge.copyWith(
                color: controller.selectedItem == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          );
        },
      ),
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
          fillColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context).colorScheme.primary;
          }),
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
          fillColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context).colorScheme.primary;
          }),
        ),
      ),
    );
  }
}
