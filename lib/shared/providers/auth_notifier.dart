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
  final UserSummaryDto? userSummary;
  final String? error;
  final bool isNewRegistration;
  final bool needsEmailVerification;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.userSummary,
    this.error,
    this.isNewRegistration = false,
    this.needsEmailVerification = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isInitial => status == AuthStatus.initial;

  /// Use full profile if available, otherwise summary.
  String get displayName =>
      user?.displayName ?? userSummary?.displayName ?? '';
  String get email => user?.email ?? userSummary?.email ?? '';

  /// Should we show onboarding?
  /// - New registration → always yes
  /// - Full profile loaded, onboardingComplete == false → yes
  /// - Otherwise (login, auto-login w/o profile yet) → no (assume done)
  bool get needsOnboarding {
    if (isNewRegistration) return true;
    if (user != null) return !user!.onboardingComplete;
    return false;
  }

  // Keep legacy getter for backward compat
  bool get onboardingComplete => !needsOnboarding;

  AuthState copyWith({
    AuthStatus? status,
    UserProfileDto? user,
    UserSummaryDto? userSummary,
    String? error,
    bool? isNewRegistration,
    bool? needsEmailVerification,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        userSummary: userSummary ?? this.userSummary,
        error: error,
        isNewRegistration: isNewRegistration ?? this.isNewRegistration,
        needsEmailVerification:
            needsEmailVerification ?? this.needsEmailVerification,
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
    bool hasToken = false;
    try {
      hasToken = await TokenService.hasTokens();
    } catch (e) {
      debugPrint('tryAutoLogin: token check failed: $e');
    }

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
      try {
        await TokenService.clearTokens();
      } catch (_) {}
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('Auto-login getProfile failed: $e');
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

      state = AuthState(
        status: AuthStatus.authenticated,
        userSummary: authResponse.user,
        isNewRegistration: true,
      );

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
    state = state.copyWith(
        status: AuthStatus.loading,
        error: null,
        needsEmailVerification: false);
    try {
      final authResponse = await _authRepo.login(LoginRequest(
        email: email,
        password: password,
      ));

      state = AuthState(
        status: AuthStatus.authenticated,
        userSummary: authResponse.user,
        isNewRegistration: false,
      );

      _loadProfileInBackground();
    } on ApiException catch (e) {
      final isVerification = e.message
          .toLowerCase()
          .contains('verify your email');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
        needsEmailVerification: isVerification,
      );
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
        // Google sign-in could be new or returning — profile will tell
        isNewRegistration: false,
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

  /// Called after onboarding is completed — clears the flag so routing shows main app.
  void markOnboardingComplete() {
    state = state.copyWith(isNewRegistration: false);
    // Also refresh profile in background to sync server state
    refreshProfile();
  }

  /// Resend email verification.
  Future<String> resendVerification(String email) async {
    try {
      final result = await _authRepo.resendVerification(email);
      return result.message;
    } catch (e) {
      return 'Failed to resend. Try again later.';
    }
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(error: null, needsEmailVerification: false);
  }

  /// Dev-mode bypass: skip auth and enter the app with mock data.
  void devBypass() {
    state = AuthState(
      status: AuthStatus.authenticated,
      user: UserProfileDto(
        id: 'dev-user-001',
        email: 'dev@manyboost.io',
        displayName: 'Dev Tester',
        avatarUrl: null,
        referralCode: 'DEVCODE',
        directInvites: 3,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        totalPoints: 4250,
        uncollectedPoints: 150,
        currentStreak: 7,
        onboardingComplete: true,
        trackedAppIds: ['instagram', 'tiktok', 'youtube'],
        spinsAvailable: 3,
      ),
      isNewRegistration: false,
    );
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
      }
    });
  }
}

// ─── Provider ───

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
