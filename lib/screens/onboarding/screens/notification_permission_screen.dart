// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              Text(
                'Reach your goals with notifications',
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 36,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'bites would like to send you Notifications',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _proceedToNextScreen(context, {
                              "notificationsEnabled": false,
                              "fcmToken": null,
                              "apnsToken": null,
                            }),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Don't Allow",
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async =>
                                await _requestNotificationPermission(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Allow',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
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
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
