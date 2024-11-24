// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/widgets/buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthService _authService;
  bool _isLoading = false;

  @override
  void initState() {
    print('LoginScreen initState called');
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    print('LoginScreen initState after Provider.of');
  }

  Future<void> _handleGoogleSignIn() async {
    print('LoginScreen _handleGoogleSignIn called');
    setState(() => _isLoading = true);

    try {
      print('Attempting to sign in with Google');
      await _authService.signInWithGoogle();
      print('Sign in with Google completed');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      print('Sign in with Google error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in. Try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Image.asset(
                'assets/images/app_logo.png',
                height: 120,
              ),
              const SizedBox(height: 32),

              // Welcome text
              Text(
                'Welcome to bites.',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Track your nutrition with the power of AI',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Sign in button
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(
                  onPressed: _handleGoogleSignIn,
                  text: 'Sign in with Google',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
