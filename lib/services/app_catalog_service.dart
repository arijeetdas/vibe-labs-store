import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_catalog_model.dart';

class AppCatalogService {
  static const String catalogUrl =
      'https://raw.githubusercontent.com/arijeetdas/vibe-labs-appstore/main/apps_catalog.json';

  /// Fetch full catalog
  static Future<List<AppEntry>> fetchCatalog() async {
    final res = await http.get(Uri.parse(catalogUrl));

    if (res.statusCode != 200) {
      throw Exception('Failed to load app catalog');
    }

    final decoded = jsonDecode(res.body);
    final List appsJson = decoded['apps'];

    return appsJson.map((e) => AppEntry.fromJson(e)).toList();
  }

  /// 🔑 REQUIRED BY DOWNLOAD PAGE / UPDATE CHECK
  static Future<List<AppEntry>> getAllApps() async {
    return await fetchCatalog();
  }

  /// Get single app by id
  static Future<AppEntry> getAppById(String id) async {
    final apps = await fetchCatalog();

    return apps.firstWhere(
      (app) => app.id == id,
      orElse: () => throw Exception('App not found: $id'),
    );
  }
}
