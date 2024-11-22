// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:bites/core/models/weight_log_model.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/services/firebase_service.dart';
import 'package:bites/core/models/user_profile_model.dart';

class DashboardController extends ChangeNotifier {
  // Services
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  // Variables
  StreamSubscription? _mealLogsSubscription;
  late final String userId;
  NutritionData _nutritionPlan = NutritionData.empty();
  List<MealLog> _todaysMealLogs = [];
  List<MealLog> _weeklyMealLogs = [];
  List<WeightLog> _weightLogs = [];
  UserProfile? _userProfile;

  // Getters
  NutritionData get nutritionPlan => _nutritionPlan;
  List<MealLog> get todaysMealLogs => _todaysMealLogs;
  List<MealLog> get weeklyMealLogs => _weeklyMealLogs;
  List<WeightLog> get weightLogs => _weightLogs;
  double? get latestWeight =>
      _weightLogs.isNotEmpty ? _weightLogs.first.weight : null;
  UserProfile? get userProfile => _userProfile;

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
      rethrow;
    }
  }

  Future<void> loadDashboardData() async {
    try {
      notifyListeners();

      // Load nutrition plan
      _nutritionPlan = await _firebaseService.getUserNutritionPlan(userId);
      // Load user profile
      final userData = await _firebaseService.getUserData(userId);
      _userProfile = UserProfile.fromMap(userData);
      // Subscribe to today's meal logs
      _mealLogsSubscription?.cancel();
      _mealLogsSubscription = _firebaseService
          .getMealLogsStream(userId: userId, date: DateTime.now())
          .listen(
        (mealLogs) {
          _todaysMealLogs = mealLogs
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
          _updateWeeklyLogs();
          notifyListeners();
        },
        onError: (e) {
          notifyListeners();
        },
      );
      await loadWeightLogs();
    } catch (e) {
      notifyListeners();
    }
  }

  void _updateWeeklyLogs() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    _weeklyMealLogs =
        await _firebaseService.getWeeklyMealLogs(userId, weekStart);
    notifyListeners();
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

  Future<void> loadWeightLogs() async {
    _firebaseService.getWeightLogs(userId).listen((logs) {
      _weightLogs = logs;
      notifyListeners();
    });
  }

  Future<void> logWeight(double weight) async {
    try {
      await _firebaseService.logWeight(userId, weight);

      // Update metrics if we have user profile
      if (_userProfile != null) {
        _userProfile!.weight = weight;
        final bmr = _calculateBMR();
        final tdee = bmr * _userProfile!.activityMultiplier;
        final dailyCalories = (tdee + _userProfile!.calorieAdjustment).round();

        await _firebaseService.updateUserData(userId, {
          'bmr': bmr,
          'tdee': tdee,
          'dailyCalories': dailyCalories,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  double _calculateBMR() {
    if (_userProfile == null) return 0;

    double bmr = (10 * _userProfile!.weight) +
        (6.25 * _userProfile!.height) -
        (5 * _userProfile!.age);
    bmr += _userProfile!.gender == 'male' ? 5 : -161;
    return bmr;
  }

  @override
  void dispose() {
    print('DashboardController dispose called');
    _mealLogsSubscription?.cancel();
    print('Meal logs subscription cancelled');
    _todaysMealLogs = [];
    _weeklyMealLogs = [];
    _weightLogs = [];
    _nutritionPlan = NutritionData.empty();
    _userProfile = null;
    print('DashboardController dispose completed');
    super.dispose();
  }
}
