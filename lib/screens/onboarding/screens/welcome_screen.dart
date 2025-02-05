// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/widgets/buttons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  // mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    Text(
                      'Welcome!',
                      style: TypographyStyles.h2(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We\'re here to help you reach your goals. \nLet\'s create a personalized plan just for you!',
                      style: TypographyStyles.body(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 32)
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Start the Quiz',
                textColor: AppColors.textPrimary,
                onPressed: () {
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  Navigator.pushNamed(
                    context,
                    '/onboarding/gender',
                    arguments: {
                      'userId': authService.currentUser!.uid,
                      'name': authService.currentUser!.displayName,
                      'email': authService.currentUser!.email,
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
