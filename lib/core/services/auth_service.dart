// Package imports:
import 'package:bites/core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _isLoading = true;
    notifyListeners();

    _currentUser = user;
    print("AuthService _onAuthStateChanged: $user and ${user?.uid}");
    if (user != null) {
      _userData = await FirebaseService().getUserData(user.uid);
    } else {
      _userData = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AuthException('Sign in aborted');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      await Future.delayed(const Duration(milliseconds: 500));
      // No need for delays - auth state listener will handle the rest
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
