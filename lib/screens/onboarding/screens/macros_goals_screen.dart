import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/models/food_model.dart';
import 'package:bites/screens/dashboard/widgets/macros_card.dart';
import 'package:flutter/material.dart';

class MacrosGoalsScreen extends StatelessWidget {
  final NutritionData dailyMacros;
  final String userId;

  const MacrosGoalsScreen({
    super.key,
    required this.dailyMacros,
    required this.userId,
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
                            targetNutrition: dailyMacros,
                            remainingNutrition: dailyMacros,
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
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/onboarding/paywall',
                    arguments: {
                      'userId': userId,
                    },
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
