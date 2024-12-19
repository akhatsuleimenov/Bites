// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Project imports:
import 'package:bites/core/services/firebase_service.dart';

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
    _userData =
        user != null ? await FirebaseService().getUserData(user.uid) : null;
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

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw AuthException('Failed to sign in with Apple: $e');
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

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await FirebaseService().createUserDocument(userCredential.user!.uid, {
          'userId': userCredential.user!.uid,
          'email': email,
          'name': name,
          'emailVisible': false,
          'dataCollectionConsent': false,
          'onboardingCompleted': false,
          'isSubscribed': false,
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Update display name after creating document
        await userCredential.user?.updateDisplayName(name);
      }
    } catch (e) {
      throw AuthException('Failed to sign up: $e');
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user signed in');

      // Delete user data from Firestore
      await FirebaseService().deleteUserData(user.uid);

      // Delete the Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException('requires-recent-login');
      }
      throw AuthException('Failed to delete account: $e');
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }

  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw AuthException('No user signed in or no email found');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw AuthException('Failed to reauthenticate: $e');
    }
  }

  Future<void> reauthenticateWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AuthException('Sign in aborted');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user signed in');

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw AuthException('Failed to reauthenticate: $e');
    }
  }

  Future<void> reauthenticateWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user signed in');

      await user.reauthenticateWithCredential(oauthCredential);
    } catch (e) {
      throw AuthException('Failed to reauthenticate: $e');
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
