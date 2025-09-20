class Launch {
  final String missionName;
  final DateTime dateUtc;
  final String rocketName;
  final String? patch;

  Launch({
    required this.missionName,
    required this.dateUtc,
    required this.rocketName,
    this.patch,
  });

  // Parse REST v3
  factory Launch.fromRestJson(Map<String, dynamic> json) {
    return Launch(
      missionName: json['mission_name'] ?? 'Unknown',
      dateUtc: DateTime.tryParse(json['launch_date_utc'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      rocketName: json['rocket']?['rocket_name'] ?? 'Unknown',
      patch: json['links']?['mission_patch_small'],
    );
  }

  // Parse GraphQL
  factory Launch.fromGraphQL(Map<String, dynamic> json) {
    return Launch(
      missionName: json['mission_name'] ?? 'Unknown',
      dateUtc: DateTime.tryParse(json['launch_date_utc'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      rocketName: json['rocket']?['rocket_name'] ?? 'Unknown',
      patch: json['links']?['mission_patch_small'],
    );
  }
}
