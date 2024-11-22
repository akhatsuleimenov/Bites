// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Project imports:
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/models/weight_log_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Meal Logs
  Future<void> saveMealLog(MealLog mealLog, String userId) async {
    try {
      final mealLogData = mealLog.toFirestore();

      // Only handle image upload if there's an image path
      if (mealLog.imagePath.isNotEmpty) {
        final imageFile = File(mealLog.imagePath);
        final storageRef = _storage
            .ref()
            .child('meal_images')
            .child(userId)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(imageFile);
        final imageUrl = await storageRef.getDownloadURL();
        mealLogData['imagePath'] = imageUrl;
      } else {
        // For manual entries, set imagePath to empty string
        mealLogData['imagePath'] = '';
      }

      await _firestore.collection('meal_logs').add(mealLogData);
    } catch (e) {
      throw FirebaseException(
        plugin: 'bites',
        message: 'Failed to save meal log: $e',
      );
    }
  }

  // Get user's nutrition plan
  Future<NutritionData> getUserNutritionPlan(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return NutritionData.empty();
      }

      final userData = userDoc.data()!;
      return NutritionData(
        calories: userData['dailyCalories'].toDouble(),
        protein: (userData['dailyCalories'] * 0.3 / 4).roundToDouble(),
        carbs: (userData['dailyCalories'] * 0.4 / 4).roundToDouble(),
        fats: (userData['dailyCalories'] * 0.3 / 9).roundToDouble(),
      );
    } catch (e) {
      throw FirebaseException(
        plugin: 'bites',
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
        .map((snapshot) =>
            snapshot.docs.map((doc) => MealLog.fromFirestore(doc)).toList());
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
        plugin: 'bites',
        message: 'Failed to delete meal log: $e',
      );
    }
  }

  // Get User Data
  Future<Map<String, dynamic>> getUserData(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data() ?? {};
  }

  // Update User Data
  Future<void> updateUserData(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection('users').doc(userId).update(updates);
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    required String userId,
    required bool enabled,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'notificationsEnabled': enabled,
      });
    } catch (e) {
      throw FirebaseException(
        plugin: 'bites',
        message: 'Failed to update notification settings: $e',
      );
    }
  }

  Stream<Map<String, dynamic>> getUserDataStream(String userId) {
    print('Starting getUserDataStream for userId: $userId');
    return _firestore.collection('users').doc(userId).snapshots().map(
      (doc) {
        print('Received user data stream update');
        return doc.data()!;
      },
    );
  }

  Future<List<MealLog>> getWeeklyMealLogs(
      String userId, DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));

    final snapshot = await _firestore
        .collection('meal_logs')
        .where('userId', isEqualTo: userId)
        .where('dateTime', isGreaterThanOrEqualTo: weekStart)
        .where('dateTime', isLessThan: weekEnd)
        .get();

    return snapshot.docs.map((doc) => MealLog.fromFirestore(doc)).toList();
  }

  Future<void> logWeight(String userId, double weight) async {
    try {
      // Log weight history
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weight_logs')
          .add({
        'weight': weight,
        'date': DateTime.now().toIso8601String(),
      });

      // Update latest weight
      updateUserData(userId, {'weight': weight});
    } catch (e) {
      throw FirebaseException(
        plugin: 'bites',
        message: 'Failed to log user weight: $e',
      );
    }
  }

  Stream<List<WeightLog>> getWeightLogs(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('weight_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WeightLog.fromJson(doc.data()))
            .toList());
  }
}
