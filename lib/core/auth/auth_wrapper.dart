// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:nutrition_ai/core/navigation/app_scaffold.dart';
import 'package:nutrition_ai/core/services/auth_service.dart';
import 'package:nutrition_ai/features/auth/screens/login_screen.dart';
import 'package:nutrition_ai/features/dashboard/controllers/dashboard_controller.dart';
import 'package:nutrition_ai/features/onboarding/screens/screens.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
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
              future: _getUserData(snapshot.data!.uid),
              builder: (context, userDataSnapshot) {
                if (userDataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
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
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return doc.exists && doc.data()?['onboardingCompleted'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return doc.data() ?? {};
    } catch (e) {
      return {};
    }
  }
}
