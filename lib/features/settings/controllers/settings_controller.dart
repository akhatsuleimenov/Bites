import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/services/auth_service.dart';
import 'package:nutrition_ai/core/services/firebase_service.dart';

class SettingsController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;

  Future<void> loadUserData() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      _userData = await _firebaseService.getUserData(userId);
      print("Loaded user data in controller: $_userData");
    } catch (e) {
      _error = e.toString();
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

      await _firebaseService.updateUserData(userId, updates);
      await loadUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
