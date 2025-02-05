// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/core/widgets/progress_app_bar.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
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
    return Scaffold(
      appBar: ProgressAppBar(
        currentStep: 1,
        totalSteps: 8,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomBackButton(),
              const SizedBox(height: 16),
              Text(
                'What is your sex?',
                style: TypographyStyles.h2(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your sex influences metabolism, helping us calculate your calorie needs more accurately.',
                style: TypographyStyles.body(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 56),
              Column(
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
              const Spacer(),
              PrimaryButton(
                textColor: AppColors.textPrimary,
                text: 'Continue',
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/onboarding/height',
                  arguments: {
                    ...widget.userData,
                    'gender': _selectedGender,
                  },
                ),
                enabled: _selectedGender != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
