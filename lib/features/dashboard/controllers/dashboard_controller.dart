import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/models/food_entry.dart';
import 'package:nutrition_ai/core/models/meal_log.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:nutrition_ai/core/services/firebase_service.dart';
import 'package:nutrition_ai/core/services/auth_service.dart';

class UserGoals {
  final int dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;

  const UserGoals({
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
  });
}

class DashboardController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  NutritionPlan? _nutritionPlan;

  NutritionPlan get nutritionPlan => _nutritionPlan ?? NutritionPlan.empty();

  Future<void> fetchNutritionPlan() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      _nutritionPlan = await _firebaseService.getUserNutritionPlan(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching nutrition plan: $e');
    }
  }

  late final String userId;
  StreamSubscription? _mealLogsSubscription;

  List<MealLog> _todaysMealLogs = [];
  bool _isLoading = true;
  String? _error;

  // Getters
  List<MealLog> get todaysMealLogs => _todaysMealLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserGoals get userGoals {
    if (_nutritionPlan == null) {
      // Return default values if nutrition plan hasn't been loaded yet
      return const UserGoals(
        dailyCalories: 2000,
        dailyProtein: 150,
        dailyCarbs: 250,
        dailyFat: 67,
      );
    }

    return UserGoals(
      dailyCalories: _nutritionPlan!.calories,
      dailyProtein: _nutritionPlan!.macros.protein,
      dailyCarbs: _nutritionPlan!.macros.carbs,
      dailyFat: _nutritionPlan!.macros.fats,
    );
  }

  DashboardController() {
    userId = FirebaseAuth.instance.currentUser!.uid;
    loadDashboardData();
  }

  @override
  void dispose() {
    _mealLogsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load nutrition plan
      _nutritionPlan = await _firebaseService.getUserNutritionPlan(userId);

      // Subscribe to meal logs
      _mealLogsSubscription?.cancel();
      _mealLogsSubscription = _firebaseService
          .getMealLogsStream(userId: userId, date: DateTime.now())
          .listen(
        (mealLogs) {
          _todaysMealLogs = mealLogs
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          print('Error loading meal logs: $e');
          _error = 'Failed to load meal logs: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      print('Error loading dashboard data: $e');
      _error = 'Failed to load dashboard data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Nutrition calculations
  int get remainingCalories {
    final consumed = _todaysMealLogs.fold(
      0,
      (sum, log) => sum + log.totalCalories.toInt(),
    );
    return (_nutritionPlan?.calories ?? 0) - consumed;
  }

  MacroNutrients get remainingMacros {
    final consumed = _calculateConsumedMacros();
    final goal = _nutritionPlan?.macros ?? MacroNutrients.empty();

    return MacroNutrients(
      protein: goal.protein - consumed.protein,
      carbs: goal.carbs - consumed.carbs,
      fats: goal.fats - consumed.fats,
    );
  }

  MacroNutrients _calculateConsumedMacros() {
    return _todaysMealLogs.fold(
      MacroNutrients.empty(),
      (sum, log) => MacroNutrients(
        protein: sum.protein + log.totalProtein,
        carbs: sum.carbs + log.totalCarbs,
        fats: sum.fats + log.totalFat,
      ),
    );
  }
}
