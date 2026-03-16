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
  final UserSummaryDto? userSummary; // from auth response (lighter)
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.userSummary,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isInitial => status == AuthStatus.initial;

  /// Use full profile if available, otherwise summary.
  String get displayName =>
      user?.displayName ?? userSummary?.displayName ?? '';
  String get email => user?.email ?? userSummary?.email ?? '';
  bool get onboardingComplete => user?.onboardingComplete ?? false;

  AuthState copyWith({
    AuthStatus? status,
    UserProfileDto? user,
    UserSummaryDto? userSummary,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        userSummary: userSummary ?? this.userSummary,
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
      debugPrint('Auto-login getProfile failed: $e');
      // Token exists but getProfile failed (maybe network issue).
      // Still authenticate — the user can try refreshing later.
      state = const AuthState(status: AuthStatus.authenticated);
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
      final authResponse = await _authRepo.register(RegisterRequest(
        email: email,
        password: password,
        displayName: displayName,
        referralCode: referralCode,
      ));

      // Use the user data from auth response directly — no extra API call!
      state = AuthState(
        status: AuthStatus.authenticated,
        userSummary: authResponse.user,
      );

      // Try loading full profile in background (non-blocking)
      _loadProfileInBackground();
    } on ApiException catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.message);
    } catch (e) {
      debugPrint('Register error: $e');
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Registration failed. Please try again.');
    }
  }

  /// Email + password login.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final authResponse = await _authRepo.login(LoginRequest(
        email: email,
        password: password,
      ));

      // Use the user data from auth response directly!
      state = AuthState(
        status: AuthStatus.authenticated,
        userSummary: authResponse.user,
      );

      // Try loading full profile in background
      _loadProfileInBackground();
    } on ApiException catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.message);
    } catch (e) {
      debugPrint('Login error: $e');
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Login failed. Please try again.');
    }
  }

  /// Google sign-in with idToken.
  Future<void> googleSignIn(String idToken, {String? referralCode}) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final authResponse = await _authRepo.googleSignIn(GoogleSignInRequest(
        idToken: idToken,
        referralCode: referralCode,
      ));

      state = AuthState(
        status: AuthStatus.authenticated,
        userSummary: authResponse.user,
      );

      _loadProfileInBackground();
    } on ApiException catch (e) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: e.message);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Google sign-in failed. Please try again.');
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
    } catch (e) {
      debugPrint('Refresh profile failed: $e');
    }
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Loads full profile in background without blocking the UI.
  void _loadProfileInBackground() {
    Future.microtask(() async {
      try {
        final profile = await _userRepo.getProfile();
        if (mounted) {
          state = state.copyWith(user: profile);
        }
      } catch (e) {
        debugPrint('Background profile load failed: $e');
        // Non-critical — user is already authenticated with summary data
      }
    });
  }
}

// ─── Provider ───

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
