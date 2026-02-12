import 'dart:io';
import 'package:flutter/services.dart';

class AppLauncher {
  static const _channel = MethodChannel('vibe_labs/app_launcher');

  static Future<void> openApp(String packageName) async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('openApp', {
        'package': packageName,
      });
    } catch (_) {
      // fail silently – never crash UI
    }
  }

  static Future<void> uninstallApp(String packageName) async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('uninstallApp', {
        'package': packageName,
      });
    } catch (_) {}
  }
}
