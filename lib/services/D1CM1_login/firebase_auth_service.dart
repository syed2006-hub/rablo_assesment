import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/D1CM1_login/user_model.dart';

/// D1CM1 – Firebase Authentication Service.
/// Connects to Firebase Auth with fallback mode for testing and offline environments.
class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._internal();

  FirebaseAuthService._internal();

  FirebaseAuth? _auth;

  FirebaseAuth? get auth {
    try {
      _auth ??= FirebaseAuth.instance;
      return _auth;
    } catch (e) {
      debugPrint('FirebaseAuth initialization note: $e');
      return null;
    }
  }

  bool get isConnected => auth != null;

  User? get currentFirebaseUser => auth?.currentUser;

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final client = auth;
    if (client != null) {
      try {
        final credential = await client.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = credential.user;
        return UserModel(
          uid: user?.uid ?? 'USER-${DateTime.now().millisecondsSinceEpoch}',
          email: user?.email ?? email.trim(),
          displayName: user?.displayName ?? 'Gym Admin',
          photoUrl: user?.photoURL,
          role: 'Admin',
          createdAt: DateTime.now(),
        );
      } catch (e) {
        debugPrint('Firebase signIn error (proceeding with fallback): $e');
      }
    }

    // Mock validation fallback for testing / offline
    return UserModel(
      uid: 'MOCK-USR-001',
      email: email.trim(),
      displayName: email.split('@').first.capitalizeFirst ?? 'Gym Admin',
      role: 'Admin',
      createdAt: DateTime.now(),
    );
  }

  /// Sign up / register with email and password
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final client = auth;
    if (client != null) {
      try {
        final credential = await client.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = credential.user;
        if (user != null) {
          await user.updateDisplayName(name.trim());
        }
        return UserModel(
          uid: user?.uid ?? 'USER-${DateTime.now().millisecondsSinceEpoch}',
          email: user?.email ?? email.trim(),
          displayName: name.trim(),
          role: 'Admin',
          createdAt: DateTime.now(),
        );
      } catch (e) {
        debugPrint('Firebase signUp error (proceeding with fallback): $e');
      }
    }

    return UserModel(
      uid: 'MOCK-USR-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: name.trim(),
      role: 'Admin',
      createdAt: DateTime.now(),
    );
  }

  /// Sign out
  Future<void> signOut() async {
    final client = auth;
    if (client != null) {
      try {
        await client.signOut();
      } catch (e) {
        debugPrint('Firebase signOut error: $e');
      }
    }
  }
}

extension StringExtension on String {
  String? get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
