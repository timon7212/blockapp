import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // TODO: Uncomment when deploying with real ads
  // await AdService.initialize();
  // await StreakService.loadStreak();

  runApp(
    const ProviderScope(
      child: ManyBoostApp(),
    ),
  );
}
