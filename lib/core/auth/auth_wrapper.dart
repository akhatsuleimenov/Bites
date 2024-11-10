import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrition_ai/core/services/auth_service.dart';
import 'package:nutrition_ai/features/auth/screens/login_screen.dart';
import 'package:nutrition_ai/features/onboarding/screens/screens.dart';
import 'package:nutrition_ai/features/dashboard/screens/dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        print('AuthWrapper: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        print('AuthWrapper: ${snapshot.hasData}');

        // If not authenticated, show login screen
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        print('AuthWrapper: ${snapshot.data!.uid}');

        // If authenticated, check if user has completed onboarding
        return FutureBuilder<bool>(
          future: _checkOnboardingStatus(snapshot.data!.uid),
          builder: (context, onboardingSnapshot) {
            print('AuthWrapper: ${onboardingSnapshot.connectionState}');
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            print('AuthWrapper: ${onboardingSnapshot.data}');
            // Show onboarding if not completed
            if (!onboardingSnapshot.data!) {
              return const WelcomeScreen();
            }
            print('AuthWrapper: onboarding completed');
            // Show dashboard if everything is set up
            return FutureBuilder<Map<String, dynamic>>(
              future: _getUserData(snapshot.data!.uid),
              builder: (context, userDataSnapshot) {
                print(
                    'AuthWrapper: userDataSnapshot: ${userDataSnapshot.connectionState}');
                if (userDataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                print(
                    'AuthWrapper: userDataSnapshot: ${userDataSnapshot.data}');
                return DashboardScreen(
                  userData: userDataSnapshot.data ?? {},
                );
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
