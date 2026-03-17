import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages JWT access & refresh tokens.
///
/// On native (Android/iOS) uses FlutterSecureStorage (encrypted keychain).
/// On Web, FlutterSecureStorage can throw OperationError (IndexedDB/WebCrypto).
/// We catch that and fall back to a simple in-memory map so the session
/// still works (tokens are lost on page reload — acceptable for dev/testing).
class TokenService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    webOptions: WebOptions(
      dbName: 'manyboost_tokens',
      publicKey: 'manyboost_public',
    ),
  );

  /// In-memory fallback when secure storage fails (web).
  static final Map<String, String> _memoryFallback = {};
  static bool _useMemoryFallback = false;

  // ─── Read ───

  static Future<String?> getAccessToken() => _read(_accessTokenKey);

  static Future<String?> getRefreshToken() => _read(_refreshTokenKey);

  static Future<bool> hasTokens() async {
    final access = await getAccessToken();
    return access != null && access.isNotEmpty;
  }

  // ─── Write ───

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _write(_accessTokenKey, accessToken),
      _write(_refreshTokenKey, refreshToken),
    ]);
  }

  static Future<void> updateAccessToken(String accessToken) =>
      _write(_accessTokenKey, accessToken);

  // ─── Clear ───

  static Future<void> clearTokens() async {
    if (_useMemoryFallback) {
      _memoryFallback.clear();
      return;
    }
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
    } catch (e) {
      debugPrint('[TokenService] clearTokens error, using memory: $e');
      _useMemoryFallback = true;
      _memoryFallback.clear();
    }
  }

  // ─── Internal helpers ───

  static Future<String?> _read(String key) async {
    if (_useMemoryFallback) {
      return _memoryFallback[key];
    }
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint(
          '[TokenService] Secure storage read failed, switching to memory fallback: $e');
      _useMemoryFallback = true;
      return _memoryFallback[key];
    }
  }

  static Future<void> _write(String key, String value) async {
    // Always save to memory so fallback works
    _memoryFallback[key] = value;

    if (_useMemoryFallback) return;

    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint(
          '[TokenService] Secure storage write failed, using memory fallback: $e');
      _useMemoryFallback = true;
      // Value is already in _memoryFallback
    }
  }
}
