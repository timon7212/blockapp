import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system/theme/app_theme.dart';
import 'shared/providers/app_providers.dart';
import 'features/shell/app_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/auth_screen.dart';

class DoomScrollApp extends ConsumerWidget {
  const DoomScrollApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider);
    final onboardingComplete = ref.watch(onboardingCompleteProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF09090B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    Widget home;
    if (!isAuthenticated) {
      home = const AuthScreen();
    } else if (!onboardingComplete) {
      home = const OnboardingScreen();
    } else {
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
