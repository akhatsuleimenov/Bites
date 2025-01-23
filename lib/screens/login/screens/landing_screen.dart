// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // App logo
              Image.asset(
                'assets/images/app_logo.jpg',
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
              const Spacer(),

              // Login button
              PrimaryButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                text: 'Login',
              ),
              const SizedBox(height: 16),

              // Register button
              PrimaryButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                text: 'Register',
                variant: ButtonVariant.outlined,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
