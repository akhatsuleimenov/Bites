// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/navigation/app_scaffold.dart';
import 'package:bites/screens/food_logging/screens/screens.dart';
import 'package:bites/screens/login/screens/landing_screen.dart';
import 'package:bites/screens/login/screens/login_screen.dart';
import 'package:bites/screens/login/screens/register_screen.dart';
import 'package:bites/screens/onboarding/screens/payment_success_screen.dart';
import 'package:bites/screens/onboarding/screens/screens.dart';
import 'package:bites/screens/settings/screens/screens.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    print('AppRoutes onGenerateRoute called with route: ${settings.name}');
    final args = settings.arguments as Map<String, dynamic>?;

    // Group routes by feature
    if (settings.name?.startsWith('/onboarding') ?? false) {
      return _handleOnboardingRoutes(settings, args);
    }

    if (settings.name?.startsWith('/settings') ?? false) {
      return _handleSettingsRoutes(settings);
    }

    // Handle main routes
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/dashboard':
      case '/analytics':
      case '/profile':
        final index = _getIndexFromRoute(settings.name!);
        return MaterialPageRoute(
          builder: (_) => AppScaffold(initialIndex: index),
          settings: settings,
        );
      case '/food-logging':
        return MaterialPageRoute(
          builder: (_) => const FoodLoggingScreen(),
          fullscreenDialog: true,
        );
      case '/food-logging/results':
        return _handleFoodLoggingResults(args);
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
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

  static Route<dynamic> _handleOnboardingRoutes(
    RouteSettings settings,
    Map<String, dynamic>? args,
  ) {
    switch (settings.name) {
      case '/onboarding/gender':
        return MaterialPageRoute(
          builder: (_) => GenderSelectionScreen(userData: args!),
        );
      case '/onboarding/height':
        return MaterialPageRoute(
          builder: (_) => HeightWeightScreen(userData: args!),
        );
      case '/onboarding/birth':
        return MaterialPageRoute(
          builder: (_) => BirthDateScreen(userData: args!),
        );
      case '/onboarding/workouts':
        return MaterialPageRoute(
          builder: (_) => WorkoutFrequencyScreen(userData: args!),
        );
      case '/onboarding/goals':
        return MaterialPageRoute(
          builder: (_) => GoalsScreen(userData: args!),
        );
      case '/onboarding/desired-weight':
        return MaterialPageRoute(
          builder: (_) => DesiredWeightScreen(userData: args!),
        );
      case '/onboarding/notifications':
        return MaterialPageRoute(
          builder: (_) => NotificationPermissionScreen(userData: args!),
        );
      case '/onboarding/calories-goals':
        return MaterialPageRoute(
          builder: (_) => CaloriesGoalsScreen(
            userData: args!,
          ),
        );
      case '/onboarding/macros-goals':
        return MaterialPageRoute(
          builder: (_) => MacrosGoalsScreen(
            userData: args!,
          ),
        );
      case '/onboarding/paywall':
        return MaterialPageRoute(
          builder: (_) => PaywallScreen(userData: args!),
        );
      case '/onboarding/payment-success':
        return MaterialPageRoute(
          builder: (_) => const PaymentSuccessScreen(),
        );
      case '/onboarding/complete':
        return MaterialPageRoute(
          builder: (_) => OnboardingCompleteScreen(userData: args!),
        );
      case '/onboarding/comparison':
        return MaterialPageRoute(
          builder: (_) => ComparisonScreen(userData: args!),
        );
      case '/onboarding/goal-speed':
        return MaterialPageRoute(
          builder: (_) => GoalSpeedScreen(userData: args!),
        );
      case '/onboarding/attainable':
        return MaterialPageRoute(
          builder: (_) => AttainableScreen(
            userData: args!,
          ),
        );
      case '/onboarding/custom-plan':
        return MaterialPageRoute(
          builder: (_) => CustomPlanScreen(
            userData: args!,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Onboarding route not found')),
          ),
        );
    }
  }

  static Route<dynamic> _handleSettingsRoutes(RouteSettings settings) {
    switch (settings.name) {
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
      case '/settings/delete-account':
        return MaterialPageRoute(builder: (_) => const DeleteAccountScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Settings route not found')),
          ),
        );
    }
  }

  static Route<dynamic> _handleFoodLoggingResults(Map<String, dynamic>? args) {
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
  }

  static int _getIndexFromRoute(String route) {
    switch (route) {
      case '/dashboard':
        return 0;
      case '/analytics':
        return 1;
      case '/profile':
        return 2;
      default:
        return 0;
    }
  }
}
