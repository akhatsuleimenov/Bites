// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bytes/core/constants/app_typography.dart';
import 'package:bytes/core/services/auth_service.dart';
import 'package:bytes/core/widgets/buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      print('Error during Google Sign-In: $e'); // Log the error
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
                'Welcome to bytes.',
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
                  // leading: Image.asset(
                  //   'assets/images/google_logo.png',
                  //   height: 24,
                  // ),
                  text: 'Sign in with Google',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
