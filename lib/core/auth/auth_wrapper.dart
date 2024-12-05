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
    print("AuthWrapper initState");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appController = Provider.of<AppController>(context, listen: false);
      print("AuthWrapper loadAppData");
      appController.loadAppData();
      print("AuthWrapper loadAppData done");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("AuthWrapper build");
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        print("AuthWrapper FutureBuilder");
        return FutureBuilder<Map<String, dynamic>?>(
          future: authService.currentUser != null
              ? FirebaseService().getUserData(authService.currentUser!.uid)
              : Future.value(null),
          builder: (context, snapshot) {
            print("AuthWrapper FutureBuilder builder");
            print("authService.currentUser: ${authService.currentUser}");
            if (snapshot.hasError) {
              print("Error fetching user data: ${snapshot.error}");
              return const LoginScreen();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            print("authService.currentUser: ${authService.currentUser}");
            // Handle authentication state first
            if (authService.currentUser == null) {
              print("login screen");
              return const LoginScreen();
            }

            final userData = snapshot.data;
            print("userData: $userData");
            print("userData?.isEmpty: ${userData?.isEmpty}");
            print("userData == null: ${userData == null}");
            if (userData == null || userData.isEmpty) {
              print("welcome screen");
              return const WelcomeScreen();
            }

            final onboardingCompleted =
                userData['onboardingCompleted'] ?? false;
            print("onboardingCompleted: $onboardingCompleted");
            if (!onboardingCompleted) {
              print("welcome screen");
              return const WelcomeScreen();
            }

            final isSubscribed = userData['isSubscribed'] ?? false;
            print("isSubscribed: $isSubscribed");
            if (!isSubscribed) {
              print("subscription screen");
              return const SubscriptionScreen();
            }

            print("app scaffold");
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
