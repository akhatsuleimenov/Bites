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
    return PopScope(
      canPop: false,
      child: Scaffold(
        drawerEdgeDragWidth: 0,
        drawerEnableOpenDragGesture: false,
        endDrawerEnableOpenDragGesture: false,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Scrollable content
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
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
                      // Add bottom padding to account for the fixed button
                      SizedBox(height: warningWidget != null ? 120 : 80),
                    ],
                  ),
                ),
              ),

              // Fixed bottom button without background
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (warningWidget != null) ...[
                      warningWidget!,
                      const SizedBox(height: 16),
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
      ),
    );
  }
}
