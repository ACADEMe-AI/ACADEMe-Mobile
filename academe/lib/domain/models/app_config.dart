import '../../config/environment.dart';

class AppConfig {
  const AppConfig({
    required this.minBuild,
    required this.recommendedBuild,
    required this.updateMessage,
    required this.updateUrl,
  });

  factory AppConfig.fromJson(Map<String, Object?> json) => AppConfig(
    minBuild: json['minBuild'] as int? ?? 0,
    recommendedBuild: json['recommendedBuild'] as int? ?? 0,
    updateMessage: json['updateMessage'] as String? ?? '',
    updateUrl: Uri.parse(
      json['updateUrl'] as String? ?? Environment.playStoreUrl.toString(),
    ),
  );

  final int minBuild;
  final int recommendedBuild;
  final String updateMessage;
  final Uri updateUrl;

  bool get mustForceUpdate =>
      minBuild > 0 && Environment.buildNumber < minBuild;

  bool get shouldSoftUpdate =>
      !mustForceUpdate &&
      recommendedBuild > 0 &&
      Environment.buildNumber < recommendedBuild;
}
