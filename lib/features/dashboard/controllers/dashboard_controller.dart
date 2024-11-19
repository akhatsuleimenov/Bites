// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:nutrition_ai/core/models/food_models.dart';
import 'package:nutrition_ai/core/services/auth_service.dart';
import 'package:nutrition_ai/core/services/firebase_service.dart';

class UserGoals {
  final double dailyCalories;
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

  NutritionData? _nutritionPlan;

  NutritionData get nutritionPlan => _nutritionPlan ?? NutritionData.empty();

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
  StreamSubscription? _weeklyLogsSubscription;

  List<MealLog> _todaysMealLogs = [];
  List<MealLog> _weeklyMealLogs = [];
  bool _isLoading = true;
  String? _error;

  // Getters
  List<MealLog> get todaysMealLogs => _todaysMealLogs;
  List<MealLog> get weeklyMealLogs => _weeklyMealLogs;
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
      dailyProtein: _nutritionPlan!.protein,
      dailyCarbs: _nutritionPlan!.carbs,
      dailyFat: _nutritionPlan!.fats,
    );
  }

  DashboardController() {
    userId = FirebaseAuth.instance.currentUser!.uid;
    loadDashboardData();
  }

  @override
  void dispose() {
    _mealLogsSubscription?.cancel();
    _weeklyLogsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load nutrition plan
      _nutritionPlan = await _firebaseService.getUserNutritionPlan(userId);

      // Subscribe to today's meal logs
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
          _error = 'Failed to load meal logs: $e';
          _isLoading = false;
          notifyListeners();
        },
      );

      // Subscribe to weekly meal logs
      _weeklyLogsSubscription?.cancel();
      _weeklyLogsSubscription =
          _firebaseService.getWeeklyMealLogsStream(userId).listen(
        (mealLogs) {
          _weeklyMealLogs = mealLogs;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Failed to load weekly logs: $e';
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to load dashboard data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Nutrition calculations
  double get remainingCalories {
    final consumed = _todaysMealLogs.fold(
      0.0,
      (sum, log) => sum + log.foodInfo.nutritionalInfo.nutritionData.calories,
    );
    return (_nutritionPlan?.calories ?? 0.0) - consumed;
  }

  NutritionData get remainingMacros {
    final consumed = _calculateConsumedMacros();
    final goal = _nutritionPlan ?? NutritionData.empty();

    return NutritionData(
      calories: goal.calories - consumed.calories,
      protein: goal.protein - consumed.protein,
      carbs: goal.carbs - consumed.carbs,
      fats: goal.fats - consumed.fats,
    );
  }

  NutritionData _calculateConsumedMacros() {
    return _todaysMealLogs.fold(
      NutritionData.empty(),
      (sum, log) => NutritionData(
        calories:
            sum.calories + log.foodInfo.nutritionalInfo.nutritionData.calories,
        protein:
            sum.protein + log.foodInfo.nutritionalInfo.nutritionData.protein,
        carbs: sum.carbs + log.foodInfo.nutritionalInfo.nutritionData.carbs,
        fats: sum.fats + log.foodInfo.nutritionalInfo.nutritionData.fats,
      ),
    );
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }
}
