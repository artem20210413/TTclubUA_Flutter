enum UpdateStatus { UP_TO_DATE, UPDATE_AVAILABLE, FORCE_UPDATE }

class AppConfigDto {
  final UpdateStatus status;
  final String? latestVersion;
  final String? storeUrl;
  final String? releaseNotes;

  AppConfigDto({
    required this.status,
    this.latestVersion,
    this.storeUrl,
    this.releaseNotes,
  });

  factory AppConfigDto.fromJson(Map<String, dynamic> json) {
    return AppConfigDto(
      status: UpdateStatus.values.firstWhere(
            (e) => e.name == json['update_status'],
        orElse: () => UpdateStatus.UP_TO_DATE,
      ),
      latestVersion: json['latest_version'],
      storeUrl: json['store_url'],
      releaseNotes: json['release_notes'],
    );
  }
}