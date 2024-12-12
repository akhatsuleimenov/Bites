// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/navigation/app_scaffold.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/screens/login/screens/login_screen.dart';
import 'package:bites/screens/onboarding/screens/screens.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        print("AuthWrapper build");
        // Show loading while auth state is changing
        if (auth.isLoading) {
          print("AuthWrapper LoadingScreen");
          return const LoadingScreen();
        }

        // Not logged in
        if (auth.currentUser == null) {
          print("AuthWrapper LoginScreen");
          return const LoginScreen();
        }

        final userData = auth.userData;
        print("AuthWrapper userData: $userData");
        // No user data yet
        if (userData == null || userData.isEmpty) {
          print("AuthWrapper WelcomeScreen");
          return const WelcomeScreen();
        }

        // Check onboarding
        if (!(userData['onboardingCompleted'] ?? false)) {
          print("AuthWrapper WelcomeScreen");
          return const WelcomeScreen();
        }

        // Check subscription
        if (!(userData['isSubscribed'] ?? false)) {
          print("AuthWrapper PaywallScreen");
          return PaywallScreen(userData: userData);
        }

        // All good 🎉
        print("AuthWrapper AppScaffold");
        return const AppScaffold();
      },
    );
  }
}

// Create this simple widget to avoid repetition
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
