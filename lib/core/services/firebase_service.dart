import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nutrition_ai/core/models/meal_log.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save meal log with image
  Future<void> saveMealLog(MealLog mealLog, String userId) async {
    try {
      // Upload image to Firebase Storage
      print(5);
      final imageFile = File(mealLog.imagePath);
      print(6);
      final storageRef = _storage
          .ref()
          .child('meal_images')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      print(7);
      print("Image path: ${imageFile}");
      await storageRef.putFile(imageFile);
      print(8);
      final imageUrl = await storageRef.getDownloadURL();
      print("HERE");
      print(imageUrl);

      // Save meal log to Firestore
      final mealLogData = mealLog.toFirestore();
      print("mealLogData");
      mealLogData['imagePath'] = imageUrl; // Update with cloud storage URL

      await _firestore.collection('meal_logs').add(mealLogData);
    } catch (e) {
      throw FirebaseException(
        plugin: 'nutrition_ai',
        message: 'Failed to save meal log: $e',
      );
    }
  }

  // Get meal logs for a user
  Stream<List<MealLog>> getMealLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore
        .collection('meal_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true);

    if (startDate != null) {
      query = query.where('dateTime', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('dateTime', isLessThanOrEqualTo: endDate);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MealLog.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }

  // Delete meal log
  Future<void> deleteMealLog(String mealLogId, String userId) async {
    try {
      final mealLog =
          await _firestore.collection('meal_logs').doc(mealLogId).get();

      if (mealLog.exists) {
        final data = mealLog.data()!;

        // Delete image from storage
        if (data['imagePath'] != null) {
          final imageRef = _storage.refFromURL(data['imagePath']);
          await imageRef.delete();
        }

        // Delete document
        await _firestore.collection('meal_logs').doc(mealLogId).delete();
      }
    } catch (e) {
      throw FirebaseException(
        plugin: 'nutrition_ai',
        message: 'Failed to delete meal log: $e',
      );
    }
  }
}
