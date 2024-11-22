// Flutter imports:
import 'package:bites/app/routes.dart';
import 'package:bites/core/auth/auth_wrapper.dart';
import 'package:bites/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'firebase_options.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/features/dashboard/controllers/dashboard_controller.dart';
import 'package:bites/features/settings/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(
            create: (context) => DashboardController(authService)),
        ChangeNotifierProvider(
            create: (context) => SettingsController(authService)),
      ],
      child: const BitesApp(),
    ),
  );
}

class BitesApp extends StatelessWidget {
  const BitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bites.',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
