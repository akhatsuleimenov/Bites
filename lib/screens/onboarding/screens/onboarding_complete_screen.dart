// Flutter imports:
import 'package:bites/core/constants/app_colors.dart';
import 'package:bites/core/utils/typography.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/services/firebase_service.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const OnboardingCompleteScreen({
    super.key,
    required this.userData,
  });

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  final List<bool> _completedSteps = List.generate(4, (_) => false);
  double _progress = 0.0;
  int _currentStepIndex = 0;
  List<int> _completedStepIndices = [];

  // Step messages with their corresponding statistics
  final List<Map<String, dynamic>> _stepMessages = [
    {
      'title': 'Analyzing your lifestyle',
      'stat': '95%',
      'description':
          'of people quit traditional diets and can\'t reach their goals.',
    },
    {
      'title': 'Counting your ideal calorie target',
      'stat': '80%',
      'description': 'of lost weight is regained within five years.',
    },
    {
      'title': 'Counting your macros',
      'stat': '65%',
      'description':
          'of dieters return to their pre-diet weight within three years.',
    },
    {
      'title': 'Finalizing the plan',
      'stat': '100%',
      'description': 'personalized plan created just for you.',
    },
  ];

  // Add a single animation controller for the steps
  late AnimationController _stepAnimationController;
  bool _isAnimatingSteps = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          _progress = _progressController.value;
          _updateSteps();
        });
      });

    // Initialize the step animation controller with longer duration
    _stepAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Increased from 600ms
    );

    _startAnimation();
  }

  void _updateSteps() {
    bool newStepAdded = false;

    if (_progress >= 0 && !_completedSteps[0]) {
      _completedSteps[0] = true;
      _currentStepIndex = 0;
      if (!_completedStepIndices.contains(0)) {
        _completedStepIndices.insert(0, 0);
        newStepAdded = true;
      }
    }
    if (_progress >= 0.25 && !_completedSteps[1]) {
      _completedSteps[1] = true;
      _currentStepIndex = 1;
      if (!_completedStepIndices.contains(1)) {
        _completedStepIndices.insert(0, 1);
        newStepAdded = true;
      }
    }
    if (_progress >= 0.5 && !_completedSteps[2]) {
      _completedSteps[2] = true;
      _currentStepIndex = 2;
      if (!_completedStepIndices.contains(2)) {
        _completedStepIndices.insert(0, 2);
        newStepAdded = true;
      }
    }
    if (_progress >= 0.75 && !_completedSteps[3]) {
      _completedSteps[3] = true;
      _currentStepIndex = 3;
      if (!_completedStepIndices.contains(3)) {
        _completedStepIndices.insert(0, 3);
        newStepAdded = true;
      }
    }

    // If a new step was added, trigger the animation
    if (newStepAdded && !_isAnimatingSteps) {
      _animateSteps();
    }
  }

  Future<void> _animateSteps() async {
    _isAnimatingSteps = true;
    _stepAnimationController.reset();
    await _stepAnimationController.forward();
    _isAnimatingSteps = false;
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _progressController.forward();
    // await FirebaseService().updateUserData(widget.userData['userId'], {
    //   ...widget.userData,
    // });
    // if (mounted) {
    //   Navigator.pushNamed(context, '/onboarding/comparison', arguments: {
    //     ...widget.userData,
    //   });
    // }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _stepAnimationController.dispose();
    super.dispose();
  }

  // Build the gradient progress indicator
  Widget _buildGradientProgressIndicator(double value) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppColors.grayBackground,
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.7),
                    AppColors.primary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the current info card with animation
  Widget _buildCurrentInfoCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(_currentStepIndex),
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _stepMessages[_currentStepIndex]['stat'],
              style: TypographyStyles.h1(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _stepMessages[_currentStepIndex]['description'],
              style: TypographyStyles.body(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Build the "But with Bites, you are different" text
  Widget _buildTagline() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        'But with Bites,\nyou are different.',
        style: TypographyStyles.h3(),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Build a single step indicator with checkmark
  Widget _buildStepIndicator(String title, bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 0),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successDefault,
              border: Border.all(
                color: AppColors.successDefault,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TypographyStyles.body(
                color: AppColors.successDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the staggered step indicators with animation
  Widget _buildStepIndicators() {
    return AnimatedBuilder(
      animation: _stepAnimationController,
      builder: (context, child) {
        return Container(
          height: 56, // Height of a single step indicator
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Show completed steps in a staggered stack
              ..._completedStepIndices
                  .asMap()
                  .entries
                  .map((entry) {
                    int index = entry.key;
                    int stepIndex = entry.value;

                    // Animation values
                    double slideValue = 0.0;
                    double scaleValue = 1.0;

                    // For the newest item (index 0), animate from bottom
                    if (index == 0) {
                      // Slide from bottom animation - reduced distance and less bouncy curve
                      slideValue = Tween<double>(
                        begin: 50.0, // Reduced from 100.0
                        end: 0.0,
                      )
                          .animate(CurvedAnimation(
                            parent: _stepAnimationController,
                            curve:
                                Curves.easeOutCubic, // Changed from elasticOut
                          ))
                          .value;
                    } else {
                      // For existing items, animate position and scale
                      double animProgress = _stepAnimationController.value;

                      // Calculate the target position
                      double targetTop = index * -4.0;
                      double targetSide = index * 4.0;

                      // Previous position (before new item was added)
                      double prevTop = (index - 1) * -4.0;
                      double prevSide = (index - 1) * 4.0;

                      // Interpolate between previous and target positions
                      double topOffset = Tween<double>(
                        begin: prevTop,
                        end: targetTop,
                      )
                          .animate(CurvedAnimation(
                            parent: _stepAnimationController,
                            curve: Curves.easeOut, // Changed from easeOutBack
                          ))
                          .value;

                      double sideOffset = Tween<double>(
                        begin: prevSide,
                        end: targetSide,
                      )
                          .animate(CurvedAnimation(
                            parent: _stepAnimationController,
                            curve: Curves.easeOut, // Changed from easeOutBack
                          ))
                          .value;

                      // Apply the calculated offsets
                      slideValue = topOffset;

                      // Scale down slightly as items move up - reduced scale change
                      scaleValue = Tween<double>(
                        begin: 1.0,
                        end: 0.97, // Changed from 0.95 for more subtle scaling
                      )
                          .animate(CurvedAnimation(
                            parent: _stepAnimationController,
                            curve: Curves.easeOut,
                          ))
                          .value;

                      // Apply the side offsets
                      return Positioned(
                        top: slideValue,
                        left: sideOffset,
                        right: sideOffset,
                        child: Transform.scale(
                          scale: scaleValue,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _buildStepIndicator(
                              _stepMessages[stepIndex]['title'],
                              true,
                            ),
                          ),
                        ),
                      );
                    }

                    // For the newest item
                    if (index == 0) {
                      return Positioned(
                        top: slideValue, // Slide from below
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _buildStepIndicator(
                            _stepMessages[stepIndex]['title'],
                            true,
                          ),
                        ),
                      );
                    }

                    // This return is for type safety, but should never be reached
                    return Positioned(child: Container());
                  })
                  .toList()
                  .reversed
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Creating a Plan for You',
                style: TypographyStyles.h2(),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // Current info card with animation
              if (_progress > 0) _buildCurrentInfoCard(),

              if (_progress > 0) _buildTagline(),

              const Spacer(),

              // Progress indicator
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: _progress),
                duration: const Duration(milliseconds: 250),
                builder: (context, double value, _) => Column(
                  children: [
                    _buildGradientProgressIndicator(value),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Use the new animated step indicators
              _buildStepIndicators(),
            ],
          ),
        ),
      ),
    );
  }
}
