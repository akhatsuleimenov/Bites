// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/widgets/buttons.dart';

class ComparisonScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ComparisonScreen({super.key, required this.userData});

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
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.errorBackground, AppColors.background],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade100, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      '95%',
                      style: TypographyStyles.headlineLarge(
                        color: AppColors.progressRed,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'of people quit traditional diets\nand can\'t reach their goals',
                      textAlign: TextAlign.center,
                      style: TypographyStyles.bodyBold(
                          color: AppColors.progressRed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'But with Bites, you\'re different',
                        style: TypographyStyles.h2(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/onboarding/attainable',
                  arguments: userData,
                ),
                textColor: AppColors.textPrimary,
                text: 'Start Your Success Story',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
