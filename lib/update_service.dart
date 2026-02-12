import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateService {
  static const String metadataUrl =
      'https://raw.githubusercontent.com/arijeetdas/vibe-labs-appstore/main/appstore_metadata.json';

  static Future<void> checkForUpdates(
    BuildContext context, {
    bool manual = false,
  }) async {
    try {
      // Skip checks if not on Android
      if (!Platform.isAndroid) return;

      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt('last_update_check') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (!manual && now - lastCheck < 12 * 60 * 60 * 1000) return;

      prefs.setInt('last_update_check', now);

      final response = await http.get(Uri.parse(metadataUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('', 408),
      );

      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final appStore = decoded['appStore'] as Map<String, dynamic>?;
      final latest = appStore?['latest'] as Map<String, dynamic>?;

      if (latest == null) return;

      final remoteVersion = latest['version'] as String?;
      if (remoteVersion == null || remoteVersion.isEmpty) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewer(remoteVersion, currentVersion) && context.mounted) {
        _showUpdateDialog(context, latest);
      }
    } on SocketException catch (e) {
      debugPrint('UpdateService: Network error - $e');
    } on TimeoutException catch (e) {
      debugPrint('UpdateService: Timeout - $e');
    } on FormatException catch (e) {
      debugPrint('UpdateService: JSON parse error - $e');
    } catch (e) {
      debugPrint('UpdateService: Unexpected error - $e');
    }
  }

  static bool _isNewer(String remote, String local) {
    final r = remote.split('.').map(int.parse).toList();
    final l = local.split('.').map(int.parse).toList();

    for (int i = 0; i < r.length; i++) {
      if (r[i] > l[i]) return true;
      if (r[i] < l[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0F),
        title: Text(
          'Update Available',
          style: GoogleFonts.interTight(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version ${data['version']}',
                style: const TextStyle(color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(height: 12),
              ...List<String>.from(data['changelog']).map(
                (e) => Text(
                  '• $e',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _downloadAndInstall(data['apk']['url']);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  static Future<void> _downloadAndInstall(String url) async {
    final dir = Directory('/storage/emulated/0/Download/VibeLabs');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File('${dir.path}/vibe_labs_update.apk');
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);

    await launchUrl(
      Uri.file(file.path),
      mode: LaunchMode.externalApplication,
    );
  }
}
