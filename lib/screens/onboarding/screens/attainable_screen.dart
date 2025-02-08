// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/utils/measurement_utils.dart';
import 'package:bites/core/widgets/buttons.dart';

class AttainableScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AttainableScreen({
    super.key,
    required this.userData,
  });

  String _getEstimatedTime(Map<String, dynamic> userData) {
    final double currentWeight = userData['weight'] as double;
    final double targetWeight = userData['targetWeight'] as double;
    final double weeklyGoal = userData['weeklyGoal'] as double;

    final double weightDifference = (currentWeight - targetWeight).abs();
    final double weeks = weightDifference / weeklyGoal;
    final int months =
        max(1, (weeks / 4.33).ceil()); // 4.33 weeks per month on average

    return months == 1 ? '1 month' : '$months months';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Your goal is completely attainable!',
                style: TypographyStyles.h2(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: AppColors.background,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Progress',
                                style: TypographyStyles.body(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                MeasurementHelper.formatWeight(
                                  userData['weeklyGoal'],
                                  userData['isMetric'] as bool,
                                  decimalPlaces: 1,
                                ),
                                style: TypographyStyles.bodyBold(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.timer,
                            color: AppColors.background,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimated Time',
                                style: TypographyStyles.body(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getEstimatedTime(userData),
                                style: TypographyStyles.bodyBold(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tips_and_updates,
                        color: AppColors.background,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pro Tip',
                      style: TypographyStyles.bodyBold(
                        color: AppColors.background,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Consistency is key! Small, sustainable changes lead to long-lasting results.',
                      style: TypographyStyles.body(
                        color: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/onboarding/custom-plan',
                  arguments: userData,
                ),
                text: 'Next',
                textColor: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
