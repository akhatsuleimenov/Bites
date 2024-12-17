// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/constants/app_typography.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/widgets/buttons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: const [
                    _WelcomePage(
                      title: 'Calorie tracking\nmade easy',
                      subtitle:
                          'Just snap a quick photo of your meal and\nwe\'ll do the rest',
                      currentPage: 0,
                    ),
                    _WelcomePage(
                      title: 'Track your progress',
                      subtitle:
                          'Set goals and monitor your daily\ncalorie intake with ease',
                      currentPage: 1,
                    ),
                    _WelcomePage(
                      title: 'Smart insights',
                      subtitle:
                          'Get personalized recommendations\nbased on your eating habits',
                      currentPage: 2,
                    ),
                    _WelcomePage(
                      title: 'Join the community',
                      subtitle:
                          'Connect with others and share\nyour healthy journey',
                      currentPage: 3,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: _currentPage == 3 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage < 3) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    final authService =
                        Provider.of<AuthService>(context, listen: false);
                    Navigator.pushNamed(context, '/onboarding/gender',
                        arguments: {
                          'userId': authService.currentUser!.uid,
                          'name': authService.currentUser!.displayName,
                          'email': authService.currentUser!.email,
                        });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final int currentPage;

  const _WelcomePage({
    required this.title,
    required this.subtitle,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _PageIndicator(
          currentPage: currentPage,
          totalPages: 4,
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          width: index == currentPage ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == currentPage
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
