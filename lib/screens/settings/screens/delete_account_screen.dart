// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/screens/settings/widgets/reauthentication_dialog.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete Your Account',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Warning: This action cannot be undone. All your data will be permanently deleted, including:',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Your profile information',
                      style: AppTypography.bodyLarge),
                  Text('• All meal logs and images',
                      style: AppTypography.bodyLarge),
                  Text('• Weight tracking history',
                      style: AppTypography.bodyLarge),
                  Text('• App settings and preferences',
                      style: AppTypography.bodyLarge),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _showDeleteConfirmation(context),
                child: const Text('Delete My Account'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Account Deletion'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteAccount(context);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user signed in')),
        );
      }
      return;
    }

    try {
      await authService.deleteAccount();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (e.toString().contains('requires-recent-login') && context.mounted) {
        final reauthenticated = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ReauthenticationDialog(
            provider: user.providerData.first.providerId,
          ),
        );

        if (reauthenticated == true && context.mounted) {
          // Try deleting again after reauthentication
          await _deleteAccount(context);
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }
}
