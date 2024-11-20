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

class DashboardController extends ChangeNotifier {
  // Services
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  // Variables
  StreamSubscription? _mealLogsSubscription;
  StreamSubscription? _weeklyLogsSubscription;
  late final String userId;
  NutritionData _nutritionPlan = NutritionData.empty();
  List<MealLog> _todaysMealLogs = [];
  List<MealLog> _weeklyMealLogs = [];

  // Getters
  NutritionData get nutritionPlan => _nutritionPlan;
  List<MealLog> get todaysMealLogs => _todaysMealLogs;
  List<MealLog> get weeklyMealLogs => _weeklyMealLogs;

  // Constructor
  DashboardController() {
    userId = FirebaseAuth.instance.currentUser!.uid;
    loadDashboardData();
  }

  // Methods
  Future<void> fetchNutritionPlan() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      _nutritionPlan = await _firebaseService.getUserNutritionPlan(userId);
      notifyListeners();
    } catch (e) {
      print('Error fetching nutrition plan: $e');
    }
  }

  Future<void> loadDashboardData() async {
    try {
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
          notifyListeners();
        },
        onError: (e) {
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
          notifyListeners();
        },
      );
    } catch (e) {
      notifyListeners();
    }
  }

  NutritionData get remainingMacros {
    final consumed = _todaysMealLogs.fold(
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

    return NutritionData(
      calories: _nutritionPlan.calories - consumed.calories,
      protein: _nutritionPlan.protein - consumed.protein,
      carbs: _nutritionPlan.carbs - consumed.carbs,
      fats: _nutritionPlan.fats - consumed.fats,
    );
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  @override
  void dispose() {
    _mealLogsSubscription?.cancel();
    _weeklyLogsSubscription?.cancel();
    super.dispose();
  }
}
