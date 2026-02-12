import 'dart:convert';
import 'package:http/http.dart' as http;

class AppStoreMetadata {
  final String version;
  final int buildNumber;
  final String apkUrl;
  final int sizeBytes;
  final String checksum;
  final List<String> changelog;
  final bool mandatory;

  AppStoreMetadata({
    required this.version,
    required this.buildNumber,
    required this.apkUrl,
    required this.sizeBytes,
    required this.checksum,
    required this.changelog,
    required this.mandatory,
  });

  factory AppStoreMetadata.fromJson(Map<String, dynamic> json) {
    final latest = json['appStore']['latest'];

    return AppStoreMetadata(
      version: latest['version'],
      buildNumber: latest['buildNumber'],
      apkUrl: latest['apk']['url'],
      sizeBytes: latest['apk']['sizeBytes'],
      checksum: latest['apk']['checksumSha256'],
      changelog: List<String>.from(latest['changelog']),
      mandatory: latest['mandatory'] ?? false,
    );
  }
}

class AppMetadataService {
  static const String metadataUrl =
      'https://raw.githubusercontent.com/arijeetdas/vibe-labs-appstore/main/appstore_metadata.json';

  static Future<AppStoreMetadata> fetchStoreMetadata() async {
    final response = await http.get(Uri.parse(metadataUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load app store metadata');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    return AppStoreMetadata.fromJson(decoded);
  }
}
