import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

class CustomPlanScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const CustomPlanScreen({
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your custom plan\nis ready!',
                        style: AppTypography.headlineLarge,
                      ),
                      const SizedBox(height: 48),
                      _buildMetricCard(
                        'Daily Calorie Target',
                        '${userData['dailyCalories'].round()}',
                        'kcal',
                        Icons.local_fire_department,
                        Colors.orange[400]!,
                        'Based on your BMR and activity level',
                      ),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        'Protein Goal',
                        '${(userData['dailyCalories'] * 0.3 / 4).round()}',
                        'g',
                        Icons.fitness_center,
                        Colors.blue[400]!,
                        'Maintain muscle mass during your journey',
                      ),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        'Carbs Goal',
                        '${(userData['dailyCalories'] * 0.4 / 4).round()}',
                        'g',
                        Icons.restaurant_menu,
                        Colors.orange[400]!,
                        'Keeps you full and satisfied',
                      ),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        'Fat Goal',
                        '${(userData['dailyCalories'] * 0.3 / 9).round()}',
                        'g',
                        Icons.food_bank,
                        Colors.green[400]!,
                        'Keeps you warm and healthy',
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.black.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.psychology,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Your Plan Includes',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
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
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/onboarding/paywall',
                  arguments: userData,
                ),
                text: "Let's Begin!",
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
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
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        unit,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[600],
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
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTypography.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
