import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_exceptions.dart';
import '../../data/dto/auth_dto.dart';
import '../../data/dto/user_dto.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/token_service.dart';

// ─── Auth State ───

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserProfileDto? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isInitial => status == AuthStatus.initial;

  AuthState copyWith({
    AuthStatus? status,
    UserProfileDto? user,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

// ─── Auth Notifier ───

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AuthNotifier({
    AuthRepository? authRepo,
    UserRepository? userRepo,
  })  : _authRepo = authRepo ?? AuthRepository(),
        _userRepo = userRepo ?? UserRepository(),
        super(const AuthState());

  /// Check if there is a saved token → try to load profile.
  Future<void> tryAutoLogin() async {
    final hasToken = await TokenService.hasTokens();
    if (!hasToken) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final profile = await _userRepo.getProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: profile,
      );
    } on UnauthorizedException {
      await TokenService.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      // Network error but token exists — still "authenticated" (offline)
      debugPrint('Auto-login failed: $e');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Email + password registration.
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? referralCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authRepo.register(RegisterRequest(
        email: email,
        password: password,
        displayName: displayName,
        referralCode: referralCode,
      ));
      // After register, load full profile
      final profile = await _userRepo.getProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: profile,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.message);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  /// Email + password login.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authRepo.login(LoginRequest(
        email: email,
        password: password,
      ));
      final profile = await _userRepo.getProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: profile,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.message);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  /// Google sign-in with idToken.
  Future<void> googleSignIn(String idToken, {String? referralCode}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authRepo.googleSignIn(GoogleSignInRequest(
        idToken: idToken,
        referralCode: referralCode,
      ));
      final profile = await _userRepo.getProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: profile,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.message);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  /// Logout.
  Future<void> logout() async {
    await _authRepo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Refresh profile from server.
  Future<void> refreshProfile() async {
    try {
      final profile = await _userRepo.getProfile();
      state = state.copyWith(user: profile);
    } catch (_) {}
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ─── Provider ───

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
