class AppEntry {
  final String id;
  final String name;
  final String packageName; // ✅ REQUIRED
  final String icon;
  final LatestRelease latest;
  final List<String> changelog;
  final List<String> screenshots;
  final String description;

  AppEntry({
    required this.id,
    required this.name,
    required this.packageName,
    required this.icon,
    required this.latest,
    required this.changelog,
    required this.screenshots,
    required this.description,
  });

  factory AppEntry.fromJson(Map<String, dynamic> json) {
    return AppEntry(
      id: json['id'],
      name: json['name'],
      packageName: json['packageName'],
      icon: json['icon'],
      latest: LatestRelease.fromJson(json['latest']),
      changelog: List<String>.from(json['changelog']),
      screenshots: List<String>.from(json['screenshots']),
      description: json['description'],
    );
  }
}

class LatestRelease {
  final String version;
  final int buildNumber;
  final int sizeBytes;
  final String apkUrl;

  LatestRelease({
    required this.version,
    required this.buildNumber,
    required this.sizeBytes,
    required this.apkUrl,
  });

  factory LatestRelease.fromJson(Map<String, dynamic> json) {
    return LatestRelease(
      version: json['version'],
      buildNumber: json['buildNumber'],
      sizeBytes: json['sizeBytes'],
      apkUrl: json['apkUrl'],
    );
  }
}
