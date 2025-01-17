// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/screens/dashboard/widgets/macros_card.dart';

class MacrosGoalsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const MacrosGoalsScreen({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Daily recommendation',
                        style: AppTypography.headlineLarge,
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          Text(
                            'Macronutrients',
                            style: AppTypography.headlineSmall,
                          ),
                          const SizedBox(height: 24),
                          NutritionGrid(
                            targetNutrition: userData['dailyMacros'],
                            remainingNutrition: userData['dailyMacros'],
                            isOnboarding: true,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'These macros are calculated based on your goals and will help you achieve optimal results',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/onboarding/paywall',
                    arguments: {'userId': userData['userId']},
                  );
                },
                text: "Let's Begin!",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
