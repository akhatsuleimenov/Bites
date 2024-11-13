import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nutrition_ai/core/models/meal_log.dart';
import 'dart:io';

import 'package:nutrition_ai/core/models/food_entry.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Meal Logs
  Future<void> saveMealLog(MealLog mealLog, String userId) async {
    try {
      // Upload image to Firebase Storage
      final imageFile = File(mealLog.imagePath);
      final storageRef = _storage
          .ref()
          .child('meal_images')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      // Save meal log to Firestore with the cloud storage URL
      final mealLogData = mealLog.toFirestore();
      mealLogData['imagePath'] = imageUrl;

      await _firestore.collection('meal_logs').add(mealLogData);
    } catch (e) {
      throw FirebaseException(
        plugin: 'nutrition_ai',
        message: 'Failed to save meal log: $e',
      );
    }
  }

  // Get user's nutrition plan
  Future<NutritionPlan?> getUserNutritionPlan(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return NutritionPlan(
        calories: userData['dailyCalories'] as int,
        macros: MacroNutrients(
          protein: (userData['dailyCalories'] * 0.3 / 4).roundToDouble(),
          carbs: (userData['dailyCalories'] * 0.4 / 4).roundToDouble(),
          fats: (userData['dailyCalories'] * 0.3 / 9).roundToDouble(),
        ),
      );
    } catch (e) {
      throw FirebaseException(
        plugin: 'nutrition_ai',
        message: 'Failed to fetch user nutrition plan: $e',
      );
    }
  }

  // Get meal logs stream
  Stream<List<MealLog>> getMealLogsStream({
    required String userId,
    required DateTime date,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('meal_logs')
        .where('userId', isEqualTo: userId)
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('dateTime', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealLog.fromFirestore(doc, null))
            .toList());
  }

  // Delete meal log
  Future<void> deleteMealLog(String mealLogId) async {
    try {
      final mealLog =
          await _firestore.collection('meal_logs').doc(mealLogId).get();

      if (mealLog.exists) {
        final data = mealLog.data()!;
        if (data['imagePath'] != null) {
          final imageRef = _storage.refFromURL(data['imagePath']);
          await imageRef.delete();
        }
        await mealLog.reference.delete();
      }
    } catch (e) {
      throw FirebaseException(
        plugin: 'nutrition_ai',
        message: 'Failed to delete meal log: $e',
      );
    }
  }
}
