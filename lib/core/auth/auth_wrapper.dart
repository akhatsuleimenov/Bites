// Flutter imports:
import 'package:bites/core/services/firebase_service.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:bites/core/navigation/app_scaffold.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/features/dashboard/controllers/dashboard_controller.dart';
import 'package:bites/features/login/screens/login_screen.dart';
import 'package:bites/features/onboarding/screens/screens.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firebaseService = FirebaseService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        print('AuthWrapper: snapshot: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper: LoadingScreen');
          return const LoadingScreen();
        }

        if (!snapshot.hasData) {
          print('AuthWrapper: LoginScreen');
          return const LoginScreen();
        }

        return FutureBuilder<Map<String, dynamic>>(
          future: firebaseService.getUserData(snapshot.data!.uid),
          builder: (context, userDataSnapshot) {
            print(
                'AuthWrapper: userDataSnapshot: ${userDataSnapshot.connectionState}');
            if (userDataSnapshot.connectionState == ConnectionState.waiting) {
              print('AuthWrapper inside FutureBuilder: LoadingScreen');
              return const LoadingScreen();
            }

            final userData = userDataSnapshot.data;
            if (userData == null || userData['onboardingCompleted'] != true) {
              print('AuthWrapper inside FutureBuilder: WelcomeScreen');
              return const WelcomeScreen();
            }

            Provider.of<DashboardController>(context, listen: false)
                .initializeData();
            return const AppScaffold(initialIndex: 0);
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
