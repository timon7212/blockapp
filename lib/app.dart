import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system/theme/app_theme.dart';
import 'shared/providers/app_providers.dart';
import 'features/shell/app_shell.dart';
import 'features/onboarding/onboarding_screen.dart';

class ManyBoostApp extends ConsumerWidget {
  const ManyBoostApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingComplete = ref.watch(onboardingCompleteProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'ManyBoost',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: onboardingComplete ? const AppShell() : const OnboardingScreen(),
    );
  }
}
