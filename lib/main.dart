// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

// Project imports:
import 'package:bites/app/routes.dart';
import 'package:bites/core/auth/auth_wrapper.dart';
import 'package:bites/core/controllers/app_controller.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/themes/app_theme.dart';
import 'package:bites/core/utils/env.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  String apiKey = await Env.superwallApiKey;
  Superwall.configure(apiKey);

  final authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (context) => AppController(authService)),
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
      // darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
