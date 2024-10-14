const maxAthleteNo = 10;

int retrieveAthleteNo(String deviceId) {
  // "athlete$num" なら num の部分を取得
  final match = RegExp(r'athlete(\d+)').firstMatch(deviceId);
  if (match == null) {
    return 0;
  }
  return int.parse(match.group(1)!);
}

// 選手の情報を表すクラス
class AthleteInfo {
  final String deviceId;
  final int nextMarkNo;
  final double latitude;
  final double longitude;
  final double accuracyMeter;
  final double heading;
  final DateTime recordedAt;

  AthleteInfo({
    required this.deviceId,
    required this.nextMarkNo,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    required this.heading,
    required this.recordedAt,
  });

  factory AthleteInfo.fromJson(Map<String, dynamic> json) {
    return AthleteInfo(
      deviceId: json['device_id'] as String,
      nextMarkNo: json['next_mark_no'] as int,
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      accuracyMeter: json['accuracy_meter'].toDouble(),
      heading: json['heading'].toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }
}
