// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/models/user_profile_model.dart';
import 'package:bites/core/models/weight_log_model.dart';
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/services/firebase_service.dart';

class AppController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService;

  // State variables
  bool _isLoading = false;
  StreamSubscription? _mealLogsSubscription;
  StreamSubscription? _authStateSubscription;
  late String userId;
  NutritionData _nutritionPlan = NutritionData.empty();
  List<MealLog> _todaysMealLogs = [];
  List<MealLog> _weeklyMealLogs = [];
  List<WeightLog> _weightLogs = [];
  UserProfile? _userProfile;

  // Getters
  bool get isLoading => _isLoading;
  NutritionData get nutritionPlan => _nutritionPlan;
  List<MealLog> get todaysMealLogs => _todaysMealLogs;
  List<MealLog> get weeklyMealLogs => _weeklyMealLogs;
  List<WeightLog> get weightLogs => _weightLogs;
  UserProfile get userProfile => _userProfile ?? UserProfile();
  double? get latestWeight =>
      _weightLogs.isNotEmpty ? _weightLogs.first.weight : null;

  AppController(this._authService) {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      print("Auth State Changed: $user");
      if (user != null) {
        print("User is not null");
        userId = user.uid;
        initializeData();
      } else {
        print("User is null");
        // Handle signed out state
        _clearData();
      }
    });
  }

  void _clearData() {
    _mealLogsSubscription?.cancel();
    _todaysMealLogs = [];
    _weeklyMealLogs = [];
    _weightLogs = [];
    _nutritionPlan = NutritionData.empty();
    _userProfile = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mealLogsSubscription?.cancel();
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeData() async {
    if (_userProfile != null) return;
    await loadAppData();
  }

  Future<void> loadAppData() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      // Only notify if not during initialization
      if (_userProfile != null) notifyListeners();

      final futures = await Future.wait([
        _firebaseService.getUserNutritionPlan(userId),
        _firebaseService.getUserData(userId),
      ]);

      _nutritionPlan = futures[0] as NutritionData;
      _userProfile = UserProfile.fromMap(futures[1] as Map<String, dynamic>);

      _setupMealLogsSubscription();
      await loadWeightLogs();
    } catch (e) {
    } finally {
      _isLoading = false;
      // Only notify if not during initialization
      if (_userProfile != null) notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firebaseService.updateUserData(userId, updates);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      await loadAppData();
      notifyListeners();
    }
  }

  void _setupMealLogsSubscription() {
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
  }

  void _updateWeeklyLogs() async {
    final currentDay = DateTime.now();

    _weeklyMealLogs =
        await _firebaseService.getWeeklyMealLogs(userId, currentDay);
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
    await loadAppData();
  }

  Future<void> loadWeightLogs() async {
    _firebaseService.getWeightLogs(userId).listen((logs) {
      _weightLogs = logs;
      notifyListeners();
    }, onError: (e) {
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
}
