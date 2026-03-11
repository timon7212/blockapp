import 'package:flutter/services.dart';

class AppBlockerService {
  static const _channel = MethodChannel('com.vitality.app_blocker');

  static Future<bool> isSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> hasPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> setBlockedApps(List<String> appIds) async {
    try {
      await _channel.invokeMethod('setBlockedApps', {'appIds': appIds});
    } on PlatformException {
      // Native side unavailable — silently ignore.
    } on MissingPluginException {
      // No native implementation registered.
    }
  }

  static Future<void> startBlocking() async {
    try {
      await _channel.invokeMethod('startBlocking');
    } on PlatformException {
      // Native side unavailable.
    } on MissingPluginException {
      // No native implementation registered.
    }
  }

  static Future<void> unlockTemporarily(int minutes) async {
    try {
      await _channel.invokeMethod('unlockTemporarily', {'minutes': minutes});
    } on PlatformException {
      // Native side unavailable.
    } on MissingPluginException {
      // No native implementation registered.
    }
  }

  static Future<void> stopBlocking() async {
    try {
      await _channel.invokeMethod('stopBlocking');
    } on PlatformException {
      // Native side unavailable.
    } on MissingPluginException {
      // No native implementation registered.
    }
  }

  static Future<bool> isBlocking() async {
    try {
      final result = await _channel.invokeMethod<bool>('isBlocking');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<int> getRemainingUnlockTime() async {
    try {
      final result =
          await _channel.invokeMethod<int>('getRemainingUnlockTime');
      return result ?? 0;
    } on PlatformException {
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }
}
