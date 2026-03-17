import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system/theme/app_theme.dart';
import 'shared/providers/auth_notifier.dart';
import 'features/shell/app_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/auth_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'shared/widgets/async_value_widget.dart';

/// Root app widget.
///
/// Flow for new users:
///   WelcomeScreen → AuthScreen (Sign Up) → OnboardingScreen → AppShell
///
/// Flow for returning users:
///   Auto-login → AppShell
///   (or if token expired: AuthScreen (Sign In) → AppShell)
class ManyBoostApp extends ConsumerStatefulWidget {
  const ManyBoostApp({super.key});

  @override
  ConsumerState<ManyBoostApp> createState() => _ManyBoostAppState();
}

class _ManyBoostAppState extends ConsumerState<ManyBoostApp> {
  /// Whether to show the welcome splash pages.
  /// Resets on each app launch for unauthenticated users.
  bool _showWelcome = true;

  /// If user taps "Sign In" from welcome, we start auth in login mode.
  bool _loginMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authNotifierProvider.notifier).tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF09090B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    Widget home;
    String screenKey;

    if (authState.isInitial) {
      // ── Splash / loading while checking token ──
      home = const _SplashScreen();
      screenKey = 'splash';
    } else if (!authState.isAuthenticated) {
      if (_showWelcome) {
        // ── Welcome slides (first impression) ──
        home = WelcomeScreen(
          key: const ValueKey('welcome'),
          onGetStarted: () => setState(() {
            _showWelcome = false;
            _loginMode = false; // default to Sign Up
          }),
          onSignIn: () => setState(() {
            _showWelcome = false;
            _loginMode = true; // go to Sign In
          }),
        );
        screenKey = 'welcome';
      } else {
        // ── Auth screen ──
        home = AuthScreen(
          key: const ValueKey('auth'),
          initialLoginMode: _loginMode,
        );
        screenKey = 'auth';
      }
    } else if (authState.needsOnboarding) {
      // ── Onboarding for new users ──
      home = const OnboardingScreen();
      screenKey = 'onboarding';
    } else {
      // ── Main app ──
      home = const AppShell();
      screenKey = 'main';
    }

    return MaterialApp(
      title: 'ManyBoost',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(screenKey),
          child: home,
        ),
      ),
    );
  }
}

// ── Splash screen (shown during auto-login check) ──

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF09090B),
      body: Center(
        child: AppLoadingWidget(),
      ),
    );
  }
}
