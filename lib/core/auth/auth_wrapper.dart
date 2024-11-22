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
  AuthWrapper({super.key});
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        print('AuthWrapper stream update. HasData: ${snapshot.hasData}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return FutureBuilder<bool>(
          future: _checkOnboardingStatus(snapshot.data!.uid),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!onboardingSnapshot.data!) {
              return const WelcomeScreen();
            }

            return FutureBuilder<Map<String, dynamic>>(
              future: _firebaseService.getUserData(snapshot.data!.uid),
              builder: (context, userDataSnapshot) {
                if (userDataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!userDataSnapshot.hasData) {
                  return const WelcomeScreen();
                }
                Provider.of<DashboardController>(context, listen: false)
                    .fetchNutritionPlan();
                return const AppScaffold(initialIndex: 0);
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _checkOnboardingStatus(String userId) async {
    try {
      final doc = await _firebaseService.getUserData(userId);
      return doc['onboardingCompleted'] == true;
    } catch (e) {
      return false;
    }
  }
}
