import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const OnboardingCompleteScreen({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.celebration,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 32),
              Text(
                'You\'re all set!',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Your personalized nutrition journey begins now.',
                style: AppTypography.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Remember: Every small step counts.\nYou\'ve got this! 💪',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Let\'s Begin!',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
