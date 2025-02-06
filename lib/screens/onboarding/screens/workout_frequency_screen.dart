// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/fitness_goals_data.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';

class WorkoutFrequencyScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const WorkoutFrequencyScreen({
    super.key,
    required this.userData,
  });

  @override
  State<WorkoutFrequencyScreen> createState() => _WorkoutFrequencyScreenState();
}

class _WorkoutFrequencyScreenState extends State<WorkoutFrequencyScreen> {
  String? _selectedFrequency;

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      currentStep: 6,
      totalSteps: 8,
      title: 'How often do you work out?',
      subtitle: 'Your activity level directly impacts your daily calorie burn.',
      enableContinue: _selectedFrequency != null,
      onContinue: () {
        final selectedFrequency = frequencies.firstWhere(
          (f) => f['id'] == _selectedFrequency,
        );

        Navigator.pushNamed(
          context,
          '/onboarding/goals',
          arguments: {
            ...widget.userData,
            'workoutFrequency': _selectedFrequency,
            'activityMultiplier': selectedFrequency['multiplier'],
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 56,
        ),
        child: Column(
          children: frequencies.map((frequency) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ChoiceButton(
                icon: frequency['icon'],
                onPressed: () => setState(() {
                  _selectedFrequency = frequency['id'];
                }),
                text: frequency['title'],
                subtitle: frequency['subtitle'],
                pressed: _selectedFrequency == frequency['id'],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
