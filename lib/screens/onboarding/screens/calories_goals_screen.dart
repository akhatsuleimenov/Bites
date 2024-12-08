import 'package:bites/core/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:intl/intl.dart';
import 'package:bites/core/models/food_model.dart';

class CaloriesGoalsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const CaloriesGoalsScreen({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final double weightDiff =
        (userData['targetWeight'] - userData['weight']).abs();
    final int weeksToGoal = (weightDiff / 0.5).ceil();
    final DateTime goalDate = now.add(Duration(days: weeksToGoal * 7));

    // Calculate macros for next screen
    final dailyMacros = NutritionData(
      calories: userData['dailyCalories'].toDouble(),
      protein: (userData['dailyCalories'] * 0.3 / 4).roundToDouble(),
      carbs: (userData['dailyCalories'] * 0.4 / 4).roundToDouble(),
      fats: (userData['dailyCalories'] * 0.3 / 9).roundToDouble(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Congratulations! Your custom plan is ready!',
                              style: AppTypography.headlineLarge,
                            ),
                            // const SizedBox(height: 8),
                            // Text(
                            //   'your custom plan is ready!',
                            //   textAlign: TextAlign.center,
                            //   style: AppTypography.headlineMedium.copyWith(
                            //     fontSize: 32,
                            //     height: 1.2,
                            //     fontWeight: FontWeight.w600,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'You should ${userData['goal'].replaceAll('_', '')}:',
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${MeasurementHelper.formatWeight(weightDiff, userData['isMetric'])} in ${weeksToGoal * 7} days',
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'by ${DateFormat('MMMM d, y').format(goalDate)}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Daily recommendation',
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Calories',
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 24),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 160,
                                  height: 160,
                                  child: CircularProgressIndicator(
                                    value: 1,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[100],
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${userData['dailyCalories'].round()}',
                                  style: AppTypography.headlineLarge.copyWith(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.grey[800],
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text:
                                            'Research shows that diet is responsible for '),
                                    TextSpan(
                                      text: '80%',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(
                                        text:
                                            ' of weight management, exercise '),
                                    const TextSpan(
                                      text: '20%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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
                    '/onboarding/macros-goals',
                    arguments: {
                      'dailyMacros': dailyMacros,
                      ...userData,
                    },
                  );
                },
                text: "Let's get started!",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
