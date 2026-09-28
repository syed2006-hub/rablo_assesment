import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service managing Firebase Authentication with safe fallback mode.
class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._internal();

  FirebaseAuthService._internal();

  FirebaseAuth? _auth;

  /// Lazily get the FirebaseAuth instance if available.
  FirebaseAuth? get auth {
    try {
      _auth ??= FirebaseAuth.instance;
      return _auth;
    } catch (e) {
      debugPrint('FirebaseAuth unavailable: $e');
      return null;
    }
  }

  /// Check whether Firebase Auth is actively initialized and available.
  bool get isAvailable => auth != null;

  /// Current user getter.
  User? get currentUser => auth?.currentUser;

  /// Sign in with email and password.
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    final client = auth;
    if (client != null) {
      try {
        return await client.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } on FirebaseAuthException {
        rethrow;
      } catch (e) {
        debugPrint('Firebase sign in error: $e');
        rethrow;
      }
    }
    // Return null if offline / fallback mode
    return null;
  }

  /// Sign up / Register with email and password.
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final client = auth;
    if (client != null) {
      try {
        final credential = await client.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (displayName != null && credential.user != null) {
          await credential.user!.updateDisplayName(displayName);
        }
        return credential;
      } on FirebaseAuthException {
        rethrow;
      } catch (e) {
        debugPrint('Firebase sign up error: $e');
        rethrow;
      }
    }
    return null;
  }

  /// Sign out current user.
  Future<void> signOut() async {
    final client = auth;
    if (client != null) {
      await client.signOut();
    }
  }
}
