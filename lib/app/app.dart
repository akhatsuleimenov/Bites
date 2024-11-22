// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/app/routes.dart';
import 'package:bites/core/auth/auth_wrapper.dart';
import 'package:bites/core/themes/app_theme.dart';

class BitesApp extends StatelessWidget {
  const BitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bites.',
      theme: AppTheme.lightTheme,
      home: AuthWrapper(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
