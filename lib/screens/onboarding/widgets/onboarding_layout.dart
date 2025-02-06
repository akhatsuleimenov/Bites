import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/core/widgets/progress_app_bar.dart';
import 'package:bites/core/widgets/buttons.dart';

class OnboardingLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onContinue;
  final bool enableContinue;
  final int currentStep;
  final int totalSteps;
  final Widget? warningWidget;

  const OnboardingLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onContinue,
    this.enableContinue = true,
    required this.currentStep,
    required this.totalSteps,
    this.warningWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
          tag: 'onboardingAppBar',
          child: ProgressAppBar(
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 0.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'onboardingBackButton',
                    child: const CustomBackButton(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TypographyStyles.h2(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TypographyStyles.body(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            child,
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                children: [
                  if (warningWidget != null) ...[
                    warningWidget!,
                    const SizedBox(height: 32),
                  ],
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: onContinue,
                    textColor: AppColors.textPrimary,
                    enabled: enableContinue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
