// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

// import 'package:app_settings/app_settings.dart';

class NotificationPermissionScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const NotificationPermissionScreen({
    super.key,
    required this.userData,
  });

  Future<void> _requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;

    // If permanently denied, open settings
    if (status.isPermanentlyDenied || status.isDenied) {
      if (!context.mounted) return;
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(child: Text('Notifications Disabled')),
          content: const Text(
            'Please enable notifications in your device settings to receive updates.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not Now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      if (!context.mounted) return;
      _proceedToNextScreen(context, false);
      return;
    }

    // Check if already denied
    if (status.isDenied) {
      final result = await Permission.notification.request();

      if (!context.mounted) return;

      _proceedToNextScreen(context, result.isGranted);
      return;
    }

    // Handle other cases
    final result = await Permission.notification.request();
    if (!context.mounted) return;
    _proceedToNextScreen(context, result.isGranted);
  }

  void _proceedToNextScreen(BuildContext context, bool isGranted) {
    Navigator.pushNamed(
      context,
      '/onboarding/complete',
      arguments: {
        ...userData,
        'notificationsEnabled': isGranted,
        'onboardingCompleted': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const Icon(
                Icons.notifications_active,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 32),
              Text(
                'One last thing...',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Would you like to receive notifications?',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Don\'t worry, we\'ll only notify you about the important stuff!\n\n'
                '• Daily reminders (if you want them)\n'
                '• Weekly progress updates\n'
                '• Achievement celebrations 🎉',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Promise we won\'t spam you with "We miss you!" messages 😉',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Enable Notifications',
                onPressed: () => _requestNotificationPermission(context),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _proceedToNextScreen(context, false);
                },
                child: Text(
                  'Maybe Later',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
