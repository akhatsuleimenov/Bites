// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/core/navigation/app_scaffold.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/screens/login/screens/login_screen.dart';
import 'package:bites/screens/onboarding/screens/screens.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appController = Provider.of<AppController>(context, listen: false);
      appController.loadAppData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.currentUser == null) {
          print('user is null, redirecting to login');
          return const LoginScreen();
        }

        return FutureBuilder<Map<String, dynamic>>(
          future: FirebaseService().getUserData(authService.currentUser!.uid),
          builder: (context, snapshot) {
            print('future builder snapshot: $snapshot');
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('waiting, showing loading screen');
              return const LoadingScreen();
            }
            print('snapshot has data, getting user data');
            final userData = snapshot.data;
            print('user data: $userData');
            if (userData == null || userData.isEmpty) {
              // User is new, redirect to onboarding
              print('user data is null or empty, redirecting to onboarding');
              return const WelcomeScreen();
            }

            final onboardingCompleted =
                userData['onboardingCompleted'] ?? false;

            print('onboarding completed: $onboardingCompleted');
            if (!onboardingCompleted) {
              print('onboarding not completed, redirecting to onboarding');
              return const WelcomeScreen();
            }

            final isSubscribed = userData['subscription'] ?? false;
            print('is subscribed: $isSubscribed');
            if (!isSubscribed) {
              print('user is not subscribed, redirecting to subscription');
              return const SubscriptionScreen();
            }

            print('onboarding completed, redirecting to app');
            return const AppScaffold();
          },
        );
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
