import 'package:flutter/material.dart';
import 'package:nutrition_ai/features/onboarding/screens/screens.dart';
import 'package:nutrition_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:nutrition_ai/features/food_logging/screens/food_logging_screen.dart';
import 'package:nutrition_ai/features/food_logging/screens/food_logging_results_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String welcome = '/welcome';
  static const String onboardingGender = '/onboarding/gender';
  static const String onboardingHeight = '/onboarding/height';
  static const String onboardingBirth = '/onboarding/birth';
  static const String onboardingWorkouts = '/onboarding/workouts';
  static const String onboardingExperience = '/onboarding/experience';
  static const String onboardingGoals = '/onboarding/goals';
  static const String onboardingDesiredWeight = '/onboarding/desired-weight';
  static const String onboardingNotifications = '/onboarding/notifications';
  static const String onboardingComplete = '/onboarding/complete';
  static const String dashboard = '/dashboard';
  static const String foodLogging = '/food-logging';
  static const String foodLoggingResults = '/food-logging/results';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Helper function to create routes with userData
    MaterialPageRoute<dynamic> buildRoute(
        Widget Function(Map<String, dynamic>) builder) {
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      return MaterialPageRoute(builder: (_) => builder(args));
    }

    // Route mapping
    final routes = {
      initial: (_) => const WelcomeScreen(),
      welcome: (_) => const WelcomeScreen(),
      onboardingGender: (_) => const GenderSelectionScreen(),
      onboardingHeight: (args) => HeightWeightScreen(userData: args),
      onboardingBirth: (args) => BirthDateScreen(userData: args),
      onboardingWorkouts: (args) => WorkoutFrequencyScreen(userData: args),
      onboardingExperience: (args) => PreviousExperienceScreen(userData: args),
      onboardingGoals: (args) => GoalsScreen(userData: args),
      onboardingDesiredWeight: (args) => DesiredWeightScreen(userData: args),
      onboardingNotifications: (args) =>
          NotificationPermissionScreen(userData: args),
      onboardingComplete: (args) => OnboardingCompleteScreen(userData: args),
      dashboard: (args) => DashboardScreen(userData: args),
      foodLogging: (_) => const FoodLoggingScreen(),
      foodLoggingResults: (args) => FoodLoggingResultsScreen(
            imagePath: args['imagePath'] as String,
            analysisResults: args['analysisResults'] as Map<String, dynamic>,
          ),
    };

    // Look up and return the route
    final routeBuilder = routes[settings.name];
    if (routeBuilder != null) {
      return buildRoute(routeBuilder);
    }

    // Default route for unknown routes
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Route ${settings.name} not found'),
        ),
      ),
    );
  }
}
