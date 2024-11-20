// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:nutrition_ai/core/constants/app_typography.dart';
import 'package:nutrition_ai/core/services/auth_service.dart';
import 'package:nutrition_ai/shared/widgets/buttons.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const OnboardingCompleteScreen({
    super.key,
    required this.userData,
  });

  Future<void> _saveUserData(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'onboardingCompleted': true,
        ...userData, // Spread the user data to save it
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar or log the error)
      print('Error saving user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser!.uid;

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
                onPressed: () async {
                  await _saveUserData(
                      userId); // Save user data before navigating
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
