import 'dart:io';
import 'package:flutter/services.dart';

class InstallStateService {
  static const MethodChannel _channel =
      MethodChannel('vibe_labs/app_launcher');

  static Future<bool> isInstalled(String packageName) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(
            'isInstalled',
            {'package': packageName},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<int> getInstalledBuild(
      String packageName) async {
    if (!Platform.isAndroid) return 0;
    try {
      final code = await _channel.invokeMethod<int>(
        'getVersionCode',
        {'package': packageName},
      );
      return code ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
