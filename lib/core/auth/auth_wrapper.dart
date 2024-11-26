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
    // Initialize after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appController = Provider.of<AppController>(context, listen: false);
      appController.loadAppData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        return FutureBuilder<Map<String, dynamic>>(
          future: FirebaseService().getUserData(authService.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            final userData = snapshot.data;
            if (userData == null) {
              return const LoginScreen();
            }

            final onboardingCompleted =
                userData['onboardingCompleted'] ?? false;
            if (!onboardingCompleted) {
              return const WelcomeScreen();
            }

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
