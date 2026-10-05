import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Authentication Token Manager
/// Manages Bearer JWT tokens, automatic header injection, refresh cycles, and 401 logouts.
class AuthTokenManager extends GetxService {
  static AuthTokenManager get to => Get.find<AuthTokenManager>();

  static const String _tokenKey = 'app_auth_bearer_token';
  static const String _refreshTokenKey = 'app_auth_refresh_token';
  static const String _tokenExpiryKey = 'app_auth_token_expiry';

  final RxString token = ''.obs;
  final RxBool isAuthenticated = false.obs;

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    initTokenManager();
  }

  /// Initialize token manager and restore stored token from persistent preferences
  Future<void> initTokenManager() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedToken = _prefs?.getString(_tokenKey) ?? '';
      if (savedToken.isNotEmpty) {
        token.value = savedToken;
        isAuthenticated.value = true;
        debugPrint('[AuthTokenManager] Restored active Bearer token.');
      } else {
        // Fallback default development token for API testing
        await setToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJNRU0tMDAxIiwibmFtZSI6Ik1hbmFnZXIiLCJpYXQiOjE3MDk1NzAwMDB9.signature');
      }
    } catch (e) {
      debugPrint('[AuthTokenManager] init error: $e');
    }
  }

  /// Get current Bearer authorization header value
  String? get authorizationHeader {
    if (token.value.isNotEmpty) {
      return 'Bearer ${token.value}';
    }
    return null;
  }

  /// Check whether the current token is expired
  bool get isTokenExpired {
    final expiryStr = _prefs?.getString(_tokenExpiryKey);
    if (expiryStr == null) return false;
    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  /// Store a new JWT token with an optional expiry
  Future<void> setToken(String newToken, {String? refreshToken, Duration? validFor}) async {
    token.value = newToken;
    isAuthenticated.value = true;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_tokenKey, newToken);

    if (refreshToken != null) {
      await _prefs!.setString(_refreshTokenKey, refreshToken);
    }
    if (validFor != null) {
      final expiryDate = DateTime.now().add(validFor).toIso8601String();
      await _prefs!.setString(_tokenExpiryKey, expiryDate);
    }
    debugPrint('[AuthTokenManager] Bearer token updated successfully.');
  }

  /// Clear token on logout or 401 Unauthorized
  Future<void> clearToken() async {
    token.value = '';
    isAuthenticated.value = false;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_refreshTokenKey);
    await _prefs!.remove(_tokenExpiryKey);
    debugPrint('[AuthTokenManager] Bearer token cleared.');
  }

  /// Simulate token refresh
  Future<String?> refreshToken() async {
    debugPrint('[AuthTokenManager] Refreshing expired token...');
    final refreshedToken = 'refreshed_jwt_${DateTime.now().millisecondsSinceEpoch}';
    await setToken(refreshedToken, validFor: const Duration(hours: 24));
    return refreshedToken;
  }
}
