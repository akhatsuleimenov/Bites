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

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _timer;

  final List<Map<String, String>> _descriptions = [
    {
      'image': 'assets/gifs/animated-meal.gif',
      'title': 'Effortless Meal Logging',
      'description':
          'Just snap a quick photo of your meal—no need for manual logging, we\'ll handle the details.'
    },
    {
      'image': 'assets/gifs/animated-brain.gif',
      'title': 'Smarter Tracking, Zero Effort',
      'description':
          'Get instant calorie and nutrition insights without the guesswork or tedious entry.'
    },
    {
      'image': 'assets/gifs/animated-clock.gif',
      'title': 'Track Anytime, Anywhere',
      'description':
          'At home, dining out, or on the go—know what\'s on your plate in seconds.'
    },
    {
      'image': 'assets/gifs/animated-wow.gif',
      'title': 'Enjoy Your Food, Stay on Track',
      'description':
          'No restrictive diets—just insights that help you make better choices while eating what you love.'
    },
    {
      'image': 'assets/gifs/animated-lock.gif',
      'title': 'Your Data, Your Privacy',
      'description':
          'We do NOT and will NEVER sell your information. Your privacy is our priority.'
    },
  ];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    // );

    _animationController.forward();
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final currentPage = _pageController.page?.toInt() ?? 0;
        final nextPage = (currentPage + 1) % _descriptions.length;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
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

              const SizedBox(height: 32),

              // PageView with overlays
              LayoutBuilder(
                builder: (context, constraints) {
                  final squareSize = constraints.maxWidth - 48;
                  return Stack(
                    children: [
                      // Static base image
                      Container(width: squareSize, height: squareSize - 48),

                      // Animated overlays
                      SizedBox(
                        width: squareSize + 16,
                        height: squareSize - 48,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _descriptions.length,
                          onPageChanged: (index) {
                            _animationController.reset();
                            _animationController.forward();
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              width: squareSize + 16,
                              height: squareSize - 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                // color: Colors.black.withOpacity(0.05),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      _descriptions[index]['image'] ?? '',
                                      fit: BoxFit.cover,
                                      width: 160,
                                      height: 160,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _descriptions[index]['title'] ?? '',
                                      style: TypographyStyles.h3(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // Description text
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      return Text(
                        _descriptions[_pageController.hasClients
                                ? (_pageController.page?.round() ?? 0)
                                : 0]['description'] ??
                            '',
                        style: TypographyStyles.subtitle(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),

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
