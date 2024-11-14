// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:nutrition_ai/app/routes.dart';
import 'package:nutrition_ai/core/auth/auth_wrapper.dart';
import 'package:nutrition_ai/core/themes/app_theme.dart';

class NutritionAIApp extends StatelessWidget {
  const NutritionAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition AI',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
