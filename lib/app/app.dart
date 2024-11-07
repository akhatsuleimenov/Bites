import 'package:flutter/material.dart';
import 'package:nutrition_ai/app/routes.dart';
import 'package:nutrition_ai/core/themes/app_theme.dart';

class NutritionAIApp extends StatelessWidget {
  const NutritionAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
