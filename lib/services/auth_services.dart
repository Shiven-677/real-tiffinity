import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // SIGN IN with Email/Password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    }
  }

  // ✅ SIGN UP with Email/Password (ADD THIS METHOD)
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Optionally send email verification
      // await credential.user?.sendEmailVerification();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
      throw 'Logout failed. Please try again.';
    }
  }

  // ERROR HANDLER
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'invalid-email':
        return 'Invalid email format';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
