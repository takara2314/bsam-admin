const badAccuracyMeterThreshold = 10;
const badElapsedTimeHourThreshold = 12;

int calcNextMarkNo(int wantMarkCounts, int passedMarkNo) {
  return passedMarkNo + 1 > wantMarkCounts ? 1 : passedMarkNo + 1;
}

int calcPrevMarkNo(int wantMarkCounts, int passedMarkNo) {
  return passedMarkNo - 1 < 1 ? wantMarkCounts : passedMarkNo - 1;
}

bool isBadAccuracyMeter(double accuracyMeter) {
  return accuracyMeter > badAccuracyMeterThreshold;
}

bool isBadElapsedTimeHour(DateTime recordedAt) {
  return DateTime.now().difference(recordedAt).inHours > badElapsedTimeHourThreshold;
}

// マークの位置情報を表すクラス
class MarkGeolocation {
  final int markNo;
  final bool stored;
  final double latitude;
  final double longitude;
  final double accuracyMeter;
  final double heading;
  final DateTime recordedAt;

  MarkGeolocation({
    required this.markNo,
    required this.stored,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    required this.heading,
    required this.recordedAt,
  });

  factory MarkGeolocation.fromJson(Map<String, dynamic> json) {
    return MarkGeolocation(
      markNo: json['mark_no'] as int,
      stored: json['stored'] as bool,
      latitude: json['latitude'].toDouble() as double,
      longitude: json['longitude'].toDouble() as double,
      accuracyMeter: json['accuracy_meter'].toDouble() as double,
      heading: json['heading'].toDouble() as double,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }
}

// マークのラベルを表すクラス
class MarkLabel {
  final int no;
  final String name;
  final String nameKatakana;

  MarkLabel(
    this.no,
    this.name,
    this.nameKatakana,
  );
}

final markLabels = Map<int, List<MarkLabel>>.from({
  1: [
    MarkLabel(1, '', ''),
  ],
  2: [
    MarkLabel(1, '上', 'カミ'),
    MarkLabel(2, '下', 'シモ'),
  ],
  3: [
    MarkLabel(1, '上', 'カミ'),
    MarkLabel(2, 'サイド', 'サイド'),
    MarkLabel(3, '下', 'シモ'),
  ],
  4: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
  ],
  5: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
  ],
  6: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
  ],
  7: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
    MarkLabel(7, '7', 'ナナ'),
  ],
  8: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
    MarkLabel(7, '7', 'ナナ'),
    MarkLabel(8, '8', 'ハチ'),
  ],
  9: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
    MarkLabel(7, '7', 'ナナ'),
    MarkLabel(8, '8', 'ハチ'),
    MarkLabel(9, '9', 'キュウ'),
  ],
  10: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
    MarkLabel(7, '7', 'ナナ'),
    MarkLabel(8, '8', 'ハチ'),
    MarkLabel(9, '9', 'キュウ'),
    MarkLabel(10, '10', 'ジュウ'),
  ]
});

MarkLabel getMarkLabel(int wantMarkCounts, int markNo) {
  if (
    !markLabels.containsKey(wantMarkCounts)
    || markNo < 1
    || markNo > markLabels[wantMarkCounts]!.length
  ) {
    throw ArgumentError('Invalid wantMarkCounts or markNo.');
  }

  return markLabels[wantMarkCounts]![markNo - 1];
}
