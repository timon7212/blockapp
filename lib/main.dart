import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/api/api_client.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.init();
  ApiClient.instance.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Suppress known Flutter Web engine bugs (ViewInsets assertion in responsive mode)
  if (kIsWeb) {
    PlatformDispatcher.instance.onError = (error, stack) {
      final msg = error.toString();
      if (msg.contains('ViewInsets') || msg.contains('isNonNegative')) {
        debugPrint('⚠ Suppressed ViewInsets error (Flutter Web engine bug)');
        return true; // handled
      }
      return false; // not handled — let it propagate
    };
  }

  runApp(
    const ProviderScope(
      child: ManyBoostApp(),
    ),
  );
}
