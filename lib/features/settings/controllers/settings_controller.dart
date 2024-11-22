// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/services/auth_service.dart';
import 'package:bites/core/services/firebase_service.dart';

class SettingsController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  Future<void> loadUserData() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      _userData = await _firebaseService.getUserData(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');
      print('Updating user data for user: $userId with updates: $updates');
      await _firebaseService.updateUserData(userId, updates);
      print('User data updated successfully');
      await loadUserData();
      print('User data loaded successfully');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
