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
      print('Starting to save meal log for user: $userId');
      final mealLogData = mealLog.toFirestore();
      print('Converted meal log to Firestore data: $mealLogData');

      // Only handle image upload if there's an image path
      if (mealLog.imagePath.isNotEmpty) {
        print('Image path exists, uploading to Storage: ${mealLog.imagePath}');
        final imageFile = File(mealLog.imagePath);
        final storageRef = _storage
            .ref()
            .child('meal_images')
            .child(userId)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        print('Uploading image to: ${storageRef.fullPath}');
        await storageRef.putFile(imageFile);
        final imageUrl = await storageRef.getDownloadURL();
        print('Image uploaded successfully. URL: $imageUrl');
        mealLogData['imagePath'] = imageUrl;
      } else {
        print('No image path, setting empty string');
        // For manual entries, set imagePath to empty string
        mealLogData['imagePath'] = '';
      }

      print('Saving meal log to Firestore with data: $mealLogData');
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_logs')
          .add(mealLogData);
      print('Successfully saved meal log with ID: ${docRef.id}');
    } catch (e, stackTrace) {
      print('❌ Error saving meal log: $e');
      print('Stack trace: $stackTrace');
      throw FirebaseException(
        plugin: 'bites',
        message: 'Failed to save meal log: $e',
      );
    }
  }

  Future<void> updateMealLog(MealLog mealLog) async {
    try {
      if (mealLog.id == null)
        throw Exception('Meal log ID is required for update');

      final mealLogData = mealLog.toFirestore();

      // If the image path is a local file path, upload it
      if (mealLog.imagePath.isNotEmpty &&
          !mealLog.imagePath.startsWith('http')) {
        final imageFile = File(mealLog.imagePath);
        final storageRef = _storage
            .ref()
            .child('meal_images')
            .child(mealLog.userId)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(imageFile);
        final imageUrl = await storageRef.getDownloadURL();
        mealLogData['imagePath'] = imageUrl;
      }

      await _firestore
          .collection('users')
          .doc(mealLog.userId)
          .collection('meal_logs')
          .doc(mealLog.id)
          .update(mealLogData);
    } catch (e) {
      throw FirebaseException(
        plugin: 'bites',
        message: 'Failed to update meal log: $e',
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

    print('🔍 Getting meal logs for userId: $userId');
    print('📅 Date range: $startOfDay to $endOfDay');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('meal_logs')
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('dateTime', isLessThan: endOfDay)
        .snapshots()
        .handleError((error) {
      print('❌ Error in meal logs stream: $error');
      // throw error;
    }).map((snapshot) {
      print('📦 Got ${snapshot.docs.length} meal logs');
      final logs = snapshot.docs.map((doc) {
        try {
          return MealLog.fromFirestore(doc);
        } catch (e) {
          print('❌ Error parsing meal log ${doc.id}: $e');
          rethrow;
        }
      }).toList();
      print('✅ Parsed ${logs.length} meal logs successfully');
      return logs;
    });
  }

  // Delete meal log
  Future<void> deleteMealLog(String userId, String mealLogId) async {
    try {
      final mealLog = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_logs')
          .doc(mealLogId)
          .get();

      if (mealLog.exists) {
        final data = mealLog.data()!;
        if (data['imagePath'] != null && data['imagePath'] != '') {
          print("IN HERE");
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
    final docRef = _firestore.collection('users').doc(userId);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set(updates);
    } else {
      await docRef.update(updates);
    }
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
        .collection('users')
        .doc(userId)
        .collection('meal_logs')
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
        message: 'Failed to log weight: $e',
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

  Future<void> deleteUserData(String userId) async {
    try {
      // Delete all meal logs
      final mealLogs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_logs')
          .get();

      for (var doc in mealLogs.docs) {
        final data = doc.data();
        // Delete associated image if exists
        if (data['imagePath'] != null && data['imagePath'].isNotEmpty) {
          try {
            final imageRef = _storage.refFromURL(data['imagePath']);
            await imageRef.delete();
          } catch (e) {
            print('Error deleting image: $e');
          }
        }
        await doc.reference.delete();
      }

      // Delete weight logs subcollection
      final weightLogs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weight_logs')
          .get();

      for (var doc in weightLogs.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw FirebaseException(
        plugin: 'bites',
        message: 'Failed to delete user data: $e',
      );
    }
  }
}
