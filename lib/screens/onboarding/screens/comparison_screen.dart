import 'package:flutter/material.dart';
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/widgets/buttons.dart';

class ComparisonScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ComparisonScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'But with Bites,\nyou\'re different',
                style: AppTypography.headlineLarge,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.red.shade100, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      '95%',
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'of people quit traditional diets\nand can\'t reach their goals',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.red.shade900,
                        height: 1.4,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/onboarding/goal-speed',
                  arguments: userData,
                ),
                text: 'Start Your Success Story',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
