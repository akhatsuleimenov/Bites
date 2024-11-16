// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:nutrition_ai/core/navigation/app_scaffold.dart';
import 'package:nutrition_ai/features/food_logging/screens/food_logging_results_screen.dart';
import 'package:nutrition_ai/features/food_logging/screens/food_logging_screen.dart';
import 'package:nutrition_ai/features/onboarding/screens/screens.dart';
import 'package:nutrition_ai/features/settings/screens/screens.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    print("ARGS SETTINGS: ${args}");

    switch (settings.name) {
      case '/':
        print('WelcomeScreen!!!');
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );

      case '/dashboard':
        print('DashboardScreen');
        return MaterialPageRoute(
          builder: (_) => const AppScaffold(initialIndex: 0),
          settings: settings,
        );

      case '/analytics':
        print('AnalyticsScreen');
        return MaterialPageRoute(
          builder: (_) => const AppScaffold(initialIndex: 1),
          settings: settings,
        );

      case '/profile':
        print('ProfileScreen');
        return MaterialPageRoute(
          builder: (_) => const AppScaffold(initialIndex: 2),
          settings: settings,
        );

      case '/food-logging':
        print('FoodLoggingScreen');
        return MaterialPageRoute(
          builder: (_) => const FoodLoggingScreen(),
          fullscreenDialog: true,
        );

      case '/food-logging/results':
        if (args == null ||
            !args.containsKey('imagePath') ||
            !args.containsKey('analysisResults')) {
          throw ArgumentError(
              'Missing required arguments for FoodLoggingResultsScreen');
        }
        return MaterialPageRoute(
          builder: (_) => FoodLoggingResultsScreen(
            imagePath: args['imagePath'] as String,
            analysisResults: args['analysisResults'] as Map<String, dynamic>,
          ),
        );

      case '/welcome':
        print('WelcomeScreen------');
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );
      case '/onboarding/gender':
        return MaterialPageRoute(
          builder: (_) => const GenderSelectionScreen(),
        );
      case '/onboarding/height':
        return MaterialPageRoute(
          builder: (_) =>
              HeightWeightScreen(userData: args as Map<String, dynamic>),
        );
      case '/onboarding/birth':
        print('BirthDateScreen');
        return MaterialPageRoute(
          builder: (_) =>
              BirthDateScreen(userData: args as Map<String, dynamic>),
        );
      case '/onboarding/workouts':
        print('WorkoutFrequencyScreen');
        return MaterialPageRoute(
          builder: (_) =>
              WorkoutFrequencyScreen(userData: args as Map<String, dynamic>),
        );
      case '/onboarding/experience':
        return MaterialPageRoute(
          builder: (_) =>
              PreviousExperienceScreen(userData: args as Map<String, dynamic>),
        );
      case '/onboarding/goals':
        return MaterialPageRoute(
          builder: (_) => GoalsScreen(userData: args as Map<String, dynamic>),
        );
      case '/onboarding/desired-weight':
        return MaterialPageRoute(
          builder: (_) =>
              DesiredWeightScreen(userData: args as Map<String, dynamic>),
        );
      case '/onboarding/notifications':
        return MaterialPageRoute(
          builder: (_) => NotificationPermissionScreen(
              userData: args as Map<String, dynamic>),
        );
      case '/onboarding/complete':
        return MaterialPageRoute(
          builder: (_) =>
              OnboardingCompleteScreen(userData: args as Map<String, dynamic>),
        );
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/settings/goals':
        return MaterialPageRoute(builder: (_) => const UpdateGoalsScreen());
      case '/settings/edit-profile':
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      // case '/settings/notifications':
      //   return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case '/settings/support':
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
      case '/settings/privacy':
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
