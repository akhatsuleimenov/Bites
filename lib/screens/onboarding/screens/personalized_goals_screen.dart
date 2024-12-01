import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:intl/intl.dart';
import 'package:bites/screens/dashboard/widgets/macros_card.dart';
import 'package:provider/provider.dart'; // Importing the macros card

class PersonalizedGoalsScreen extends StatelessWidget {
  const PersonalizedGoalsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser!.uid;

    return FutureBuilder<Map<String, dynamic>>(
      future: FirebaseService()
          .getUserData(userId), // Fetch user data from Firebase
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}')); // Handle error
        }
        final userData = snapshot.data!; // Get user data
        print(userData);
        userData['remainingCalories'] = userData['dailyCalories'] / 2;
        userData['dailyMacros'] = NutritionData(
          calories: userData['dailyCalories'].toDouble(),
          protein: (userData['dailyCalories'] * 0.3 / 4).roundToDouble(),
          carbs: (userData['dailyCalories'] * 0.4 / 4).roundToDouble(),
          fats: (userData['dailyCalories'] * 0.3 / 9).roundToDouble(),
        );
        userData['remainingMacros'] = NutritionData(
          calories: userData['dailyCalories'].toDouble() / 2,
          protein: (userData['dailyCalories'] * 0.3 / 4 / 2).roundToDouble(),
          carbs: (userData['dailyCalories'] * 0.4 / 4 / 2).roundToDouble(),
          fats: (userData['dailyCalories'] * 0.3 / 9 / 2).roundToDouble(),
        );
        final DateTime now = DateTime.now();
        final double weeklyWeightChange = userData['goal'] == 'weight_loss'
            ? -0.5
            : userData['goal'] == 'weight_gain'
                ? 0.25
                : 0.0;
        final double weightDifference =
            (userData['targetWeight'] - userData['weight']).abs();
        final int weeksToGoal = weeklyWeightChange == 0
            ? 8
            : (weightDifference / weeklyWeightChange).ceil();
        final DateTime goalDate = now.add(Duration(days: weeksToGoal * 7));

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Your Personalized Plan',
                      style: AppTypography.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Updated Goal Timeline
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'You should ${userData['goal'].replaceAll('_', ' ')}',
                            style: AppTypography.bodyLarge,
                          ),
                          Text(
                            '${MeasurementHelper.formatWeight(userData['targetWeight'], userData['isMetric'])} by ${DateFormat('MMMM d, y').format(goalDate)}',
                            style: AppTypography.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Circular progress for Daily Calories
                  CalorieCard(
                    targetCalories: userData['dailyCalories'].toDouble(),
                    remainingCalories: userData['remainingCalories'].toDouble(),
                    isOnboarding: true,
                  ),
                  const SizedBox(height: 16),
                  // Circular progress for Daily Macros
                  NutritionGrid(
                    targetNutrition: userData['dailyMacros'],
                    remainingNutrition: userData['remainingMacros'],
                    isOnboarding: true,
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/onboarding/subscription',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
