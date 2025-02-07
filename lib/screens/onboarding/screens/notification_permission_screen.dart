// Flutter imports:

import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/services/firebase_service.dart';

class NotificationPermissionScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final FirebaseService _firebaseService = FirebaseService();

  NotificationPermissionScreen({
    super.key,
    required this.userData,
  });

  Future<void> _requestNotificationPermission(BuildContext context) async {
    Map<String, dynamic> result =
        await _firebaseService.initNotifications(userData['userId']);
    _proceedToNextScreen(context, result);
  }

  void _proceedToNextScreen(BuildContext context, Map<String, dynamic> result) {
    Navigator.pushNamed(
      context,
      '/onboarding/complete',
      arguments: {
        ...userData,
        ...result,
        'onboardingCompleted': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              Text(
                'Stay on track with notifications',
                style: TypographyStyles.h2(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grayBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.notifications_active,
                      title: 'Smart Reminders',
                      subtitle: 'Get gentle nudges at the right time',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.celebration,
                      title: 'Milestone Celebrations',
                      subtitle: 'Celebrate your achievements with us',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.insights,
                      title: 'Progress Updates',
                      subtitle: 'Track your journey to success',
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: () => _proceedToNextScreen(context, {
                              "notificationsEnabled": false,
                              "fcmToken": null,
                              "apnsToken": null,
                            }),
                            text: "Don't Allow",
                            variant: ButtonVariant.outlined,
                            textColor: AppColors.textSecondary,
                            color: Colors.transparent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            onPressed: () async =>
                                await _requestNotificationPermission(context),
                            text: 'Allow',
                            color: AppColors.primary,
                            textColor: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.inputBorder,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
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
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TypographyStyles.body(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
