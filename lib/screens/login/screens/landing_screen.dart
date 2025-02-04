// Flutter imports:
import 'dart:async';
import 'package:flutter/material.dart';

// External package
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import 'package:bites/core/utils/typography.dart';
import 'package:bites/core/widgets/buttons.dart';
import 'package:bites/core/constants/app_colors.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _timer;

  final List<String> _descriptions = [
    'Just snap a quick photo of your meal and we\'ll do the rest',
    'Set goals and monitor your daily calorie intake with ease',
    'Get personalized recommendations based on your eating habits',
  ];

  final List<String> _images = [
    'assets/images/scanfood.png',
    'assets/images/scanfood.png',
    'assets/images/scanfood.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage =
            (_pageController.page!.toInt() + 1) % _descriptions.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              // App logo
              Image.asset(
                'assets/images/launchImage.png',
                height: 64,
              ),
              const SizedBox(height: 16),

              // Welcome text
              Text(
                'Calorie Tracking\nMade Easy',
                style: TypographyStyles.h2(),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // PageView for smooth indicator
              LayoutBuilder(
                builder: (context, constraints) {
                  final squareSize = constraints.maxWidth - 32;
                  return SizedBox(
                    height: squareSize + 30, // square image + text height
                    width: squareSize + 32,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _descriptions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Container(
                                width: squareSize,
                                height: squareSize - 16,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    _images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: Text(
                                  _descriptions[index],
                                  style: TypographyStyles.body(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Page Indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: _descriptions.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.black,
                  dotHeight: 6,
                  dotWidth: 6,
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Login button
                    PrimaryButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      text: 'Sign Up For Free',
                      textColor: AppColors.textPrimary,
                    ),

                    const SizedBox(height: 8),

                    // Register button
                    PrimaryButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      text: 'Login',
                      color: AppColors.background,
                      textColor: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
