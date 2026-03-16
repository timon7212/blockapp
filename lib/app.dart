import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system/theme/app_theme.dart';
import 'shared/providers/auth_notifier.dart';
import 'features/shell/app_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/auth_screen.dart';
import 'shared/widgets/async_value_widget.dart';

class DoomScrollApp extends ConsumerStatefulWidget {
  const DoomScrollApp({super.key});

  @override
  ConsumerState<DoomScrollApp> createState() => _DoomScrollAppState();
}

class _DoomScrollAppState extends ConsumerState<DoomScrollApp> {
  @override
  void initState() {
    super.initState();
    // Try auto-login on startup
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
    if (authState.isInitial) {
      // Splash / loading while checking token
      home = const _SplashScreen();
    } else if (!authState.isAuthenticated) {
      home = const AuthScreen();
    } else if (authState.onboardingComplete == false &&
        authState.user != null) {
      // Only show onboarding if we have full profile and it's not complete
      home = const OnboardingScreen();
    } else {
      // Authenticated → show main app (even if profile hasn't loaded yet)
      home = const AppShell();
    }

    return MaterialApp(
      title: 'DoomScroll',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: home,
    );
  }
}

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
