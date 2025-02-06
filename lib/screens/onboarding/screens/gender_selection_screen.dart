// Flutter imports:
import 'package:bites/screens/onboarding/widgets/warning.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/screens/onboarding/widgets/onboarding_layout.dart';
import 'package:bites/core/widgets/buttons.dart';

class GenderSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const GenderSelectionScreen({
    super.key,
    required this.userData,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      currentStep: 1,
      totalSteps: 8,
      title: 'What is your sex?',
      subtitle:
          'Your sex influences metabolism, helping us calculate your calorie needs more accurately.',
      enableContinue: _selectedGender != null,
      onContinue: () => Navigator.pushNamed(
        context,
        '/onboarding/birth',
        arguments: {
          ...widget.userData,
          'gender': _selectedGender,
        },
      ),
      warningWidget: _selectedGender == 'prefer_not_to_say'
          ? const WarningMessage(
              text:
                  'Not specifying your sex will make the calculations less accurate and may slow down your progress.',
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ChoiceButton(
              icon: Icons.male,
              onPressed: () => setState(() => _selectedGender = 'male'),
              text: 'Male',
              pressed: _selectedGender == 'male',
            ),
            const SizedBox(height: 8),
            ChoiceButton(
              icon: Icons.female,
              onPressed: () => setState(() => _selectedGender = 'female'),
              text: 'Female',
              pressed: _selectedGender == 'female',
            ),
            const SizedBox(height: 8),
            ChoiceButton(
              icon: Icons.gps_not_fixed,
              onPressed: () =>
                  setState(() => _selectedGender = 'prefer_not_to_say'),
              text: 'Prefer Not To Say',
              pressed: _selectedGender == 'prefer_not_to_say',
            ),
          ],
        ),
      ),
    );
  }
}
