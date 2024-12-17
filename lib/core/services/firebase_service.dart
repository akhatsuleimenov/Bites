// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Project imports:
import 'package:bites/core/models/food_model.dart';
import 'package:bites/core/models/weight_log_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<Map<String, dynamic>> initNotifications(String userId) async {
    try {
      NotificationSettings settings = await _messaging.requestPermission();
      print('Notification settings: ${settings.authorizationStatus}');
      String? apnsToken;
      if (Platform.isIOS) {
        apnsToken = await _messaging.getAPNSToken();
        print('APNS Token: $apnsToken');
        // Wait for APNS token if not available
        if (apnsToken == null) {
          // Try a few times with delay
          for (int i = 0; i < 3; i++) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await _messaging.getAPNSToken();
            print('APNS Token after delay $i: $apnsToken');
            if (apnsToken != null) break;
          }
        }
      }

      String? fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        for (int i = 0; i < 3; i++) {
          await Future.delayed(const Duration(seconds: 1));
          fcmToken = await _messaging.getToken();
          if (fcmToken != null) break;
        }
      }

      return {
        "notificationsEnabled":
            settings.authorizationStatus == AuthorizationStatus.authorized,
        "fcmToken": fcmToken,
        "apnsToken": apnsToken,
      };
    } catch (e) {
      print('Error initializing notifications: $e');
      return {
        "notificationsEnabled": false,
        "fcmToken": null,
        "apnsToken": null,
      };
    }
  }

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
        .handleError((error) {
      // throw error;
    }).map((snapshot) =>
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
  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() ?? {};
    } catch (e) {
      print("Firestore Error: $e");
      rethrow;
    }
  }

  // Update User Data
  Future<void> updateUserData(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection('users').doc(userId).update(updates);
  }

  // Create User Document
  Future<void> createUserDocument(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    await _firestore.collection('users').doc(userId).set(userData);
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
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .handleError((error) {
      // Silently handle permission errors

      if (error.toString().contains('permission-denied')) {
        return <String, dynamic>{};
      }
      // throw error;
    }).map((doc) {
      if (!doc.exists) return <String, dynamic>{};
      return doc.data()!;
    });
  }

  Future<List<MealLog>> getWeeklyMealLogs(
      String userId, DateTime currentDay) async {
    final pastWeek = currentDay.subtract(Duration(days: 7));

    final snapshot = await _firestore
        .collection('meal_logs')
        .where('userId', isEqualTo: userId)
        .where('dateTime', isGreaterThanOrEqualTo: pastWeek)
        .where('dateTime', isLessThan: currentDay)
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
        .handleError((error) {
      // throw error;
    }).map((snapshot) => snapshot.docs
            .map((doc) => WeightLog.fromJson(doc.data()))
            .toList());
  }
}
