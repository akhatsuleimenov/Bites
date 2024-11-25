// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

class NotificationPermissionScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const NotificationPermissionScreen({
    super.key,
    required this.userData,
  });

  Future<void> _requestNotificationPermission(BuildContext context) async {
    if (await Permission.notification.shouldShowRequestRationale) {
      print('shouldShowRequestRationale');
      // Show custom dialog explaining why we need permissions
      if (!context.mounted) return;
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'We need notification permissions to send you daily reminders and progress updates.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not Now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      print(shouldRequest);
      if (shouldRequest != true) {
        if (!context.mounted) return;
        _proceedToNextScreen(context, false);
        return;
      }
    }

    final result = await Permission.notification.request();
    print("result: $result");
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
                  Navigator.pushNamed(
                    context,
                    '/onboarding/complete',
                    arguments: {
                      ...userData,
                      'notificationsEnabled': false,
                    },
                  );
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
