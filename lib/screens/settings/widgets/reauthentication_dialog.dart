// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/services/auth_service.dart';

class ReauthenticationDialog extends StatefulWidget {
  final String provider;

  const ReauthenticationDialog({
    super.key,
    required this.provider,
  });

  @override
  State<ReauthenticationDialog> createState() => _ReauthenticationDialogState();
}

class _ReauthenticationDialogState extends State<ReauthenticationDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _reauthenticate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      switch (widget.provider) {
        case 'password':
          await authService
              .reauthenticateWithPassword(_passwordController.text);
          break;
        case 'google.com':
          await authService.reauthenticateWithGoogle();
          break;
        case 'apple.com':
          await authService.reauthenticateWithApple();
          break;
        default:
          throw Exception('Unsupported provider');
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify It\'s You'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'For your security, please verify your identity before proceeding.',
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (widget.provider == 'password') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _reauthenticate,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.provider == 'password' ? 'Verify' : 'Continue'),
        ),
      ],
    );
  }
}
