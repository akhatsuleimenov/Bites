// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

// Project imports:
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/core/widgets/buttons.dart';

class CustomPlanScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const CustomPlanScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your custom plan is ready!',
                        style: TypographyStyles.h2(),
                      ),
                      const SizedBox(height: 32),
                      _buildMetricCard(
                        'Daily Calorie Target',
                        '${userData['dailyCalories'].round()}',
                        'kcal',
                        Icons.local_fire_department,
                        AppColors.error,
                        'Based on your BMR and activity level',
                      ),
                      const SizedBox(height: 8),
                      _buildMetricCard(
                        'Protein Goal',
                        '${(userData['dailyCalories'] * 0.3 / 4).round()}',
                        'g',
                        Icons.fitness_center,
                        AppColors.warning,
                        'Maintain muscle mass during your journey',
                      ),
                      const SizedBox(height: 8),
                      _buildMetricCard(
                        'Carbs Goal',
                        '${(userData['dailyCalories'] * 0.4 / 4).round()}',
                        'g',
                        Icons.restaurant_menu,
                        AppColors.error,
                        'Keeps you full and satisfied',
                      ),
                      const SizedBox(height: 8),
                      _buildMetricCard(
                        'Fat Goal',
                        '${(userData['dailyCalories'] * 0.3 / 9).round()}',
                        'g',
                        Icons.food_bank,
                        AppColors.success,
                        'Keeps you warm and healthy',
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.textPrimary,
                              AppColors.textPrimary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.psychology,
                                    color: AppColors.textPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Your Plan Includes',
                                  style: TypographyStyles.bodyBold(
                                    color: AppColors.background,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildPlanFeature(
                              'AI-powered meal rec',
                              Icons.restaurant_menu,
                            ),
                            const SizedBox(height: 16),
                            _buildPlanFeature(
                              'Weekly progress tracking',
                              Icons.trending_up,
                            ),
                            const SizedBox(height: 16),
                            _buildPlanFeature(
                              'Personalized nutrition advice',
                              Icons.psychology,
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
                  Superwall.shared.registerEvent('Subscribe', feature: () {
                    FirebaseService().updateUserData(userData['userId'], {
                      'isSubscribed': true,
                    });
                    Navigator.pushNamed(context, '/onboarding/payment-success');
                  });
                },
                text: "Let's Begin!",
                textColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TypographyStyles.bodyBold(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: TypographyStyles.bodyBold(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        unit,
                        style: TypographyStyles.body(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TypographyStyles.subtitle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanFeature(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.background,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TypographyStyles.body(
            color: AppColors.background,
          ),
        ),
      ],
    );
  }
}
