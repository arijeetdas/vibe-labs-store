class AppModel {
  final String id;
  final String name;
  final String icon;
  final String status;
  final String version;
  final bool isLatest;
  final bool isComingSoon;

  AppModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.status,
    required this.version,
    required this.isLatest,
    required this.isComingSoon,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      status: json['status'],
      version: json['version'],
      isLatest: json['isLatest'] ?? false,
      isComingSoon: json['isComingSoon'] ?? false,
    );
  }
}
