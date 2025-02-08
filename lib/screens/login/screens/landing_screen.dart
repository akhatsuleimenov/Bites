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

  final List<String> _descriptions = [
    'Just snap a quick photo of your meal and we\'ll do the rest',
    'Set goals and monitor your daily calorie intake with ease',
    'Get personalized recommendations based on your eating habits',
  ];

  final List<String> _images = [
    'assets/images/photofood.png',
    'assets/images/scanfood.png',
    'assets/images/scanfood.png',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _startAutoSwipe();
  }

  void _startAutoSwipe() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final currentPage = _pageController.page?.toInt() ?? 0;
        final nextPage = (currentPage + 1) % _descriptions.length;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
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

              const SizedBox(height: 16),

              // PageView with overlays
              LayoutBuilder(
                builder: (context, constraints) {
                  final squareSize = constraints.maxWidth - 48;
                  return Stack(
                    children: [
                      // Static base image
                      Container(
                        width: squareSize,
                        height: squareSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/photofood.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Animated overlays
                      SizedBox(
                        width: squareSize,
                        height: squareSize,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _descriptions.length,
                          onPageChanged: (index) {
                            _animationController.reset();
                            _animationController.forward();
                          },
                          itemBuilder: (context, index) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: squareSize,
                                height: squareSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black.withOpacity(0.05),
                                ),
                                child: Center(
                                    // child: Icon(
                                    //   index == 0
                                    //       ? Icons.camera_alt
                                    //       : index == 1
                                    //           ? Icons.track_changes
                                    //           : Icons.recommend,
                                    //   size: 48,
                                    //   color: Colors.white,
                                    // ),
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
                            : 0],
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
