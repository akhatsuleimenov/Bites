// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/navigation/app_scaffold.dart';
import 'package:bites/features/food_logging/screens/screens.dart';
import 'package:bites/features/login/screens/login_screen.dart';
import 'package:bites/features/onboarding/screens/screens.dart';
import 'package:bites/features/settings/screens/screens.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const AppScaffold(initialIndex: 0),
          settings: settings,
        );

      case '/analytics':
        return MaterialPageRoute(
          builder: (_) => const AppScaffold(initialIndex: 1),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const AppScaffold(initialIndex: 2),
          settings: settings,
        );

      case '/food-logging':
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
        return MaterialPageRoute(
          builder: (_) =>
              BirthDateScreen(userData: args as Map<String, dynamic>),
        );
      case '/onboarding/workouts':
        return MaterialPageRoute(
          builder: (_) =>
              WorkoutFrequencyScreen(userData: args as Map<String, dynamic>),
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
      case '/settings/support':
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
      case '/settings/privacy':
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case '/add-log':
        return MaterialPageRoute(builder: (_) => const AddLogMenuScreen());
      case '/manual-entry':
        return MaterialPageRoute(builder: (_) => const ManualEntryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
