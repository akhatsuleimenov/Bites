import 'package:flutter/material.dart';
import 'package:nutrition_ai/core/services/auth_service.dart';
import 'package:nutrition_ai/core/services/firebase_service.dart';

class ProfileController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userData => _userData;
  String? get error => _error;

  ProfileController() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      _userData = await _firebaseService.getUserData(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  Future<void> updateUserData(Map<String, dynamic> updates) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firebaseService.updateUserData(userId, updates);
      await loadUserData(); // Reload data after update
    } catch (e) {
      rethrow;
    }
  }
}
