import 'package:bsam_admin/domain/mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';

// ゲームクライアントの状態を表す不変なクラス
@immutable
class GameClientState {
  final bool connected;
  final bool authed;
  final bool started;
  final List<MarkGeolocation>? marks;
  final int nextMarkNo;
  final GeolocationState? geolocation;
  final double? compassDegree;
  final double? distanceToNextMarkMeter;

  const GameClientState({
    required this.connected,
    required this.authed,
    required this.started,
    required this.marks,
    required this.nextMarkNo,
    required this.geolocation,
    required this.compassDegree,
    required this.distanceToNextMarkMeter,
  });

  // 状態を更新するためのcopyWithメソッド
  GameClientState copyWith({
    bool? connected,
    bool? authed,
    bool? started,
    List<MarkGeolocation>? marks,
    int? nextMarkNo,
    GeolocationState? geolocation,
    double? compassDegree,
    double? distanceToNextMarkMeter,
  }) {
    return GameClientState(
      connected: connected ?? this.connected,
      authed: authed ?? this.authed,
      started: started ?? this.started,
      marks: marks ?? this.marks,
      nextMarkNo: nextMarkNo ?? this.nextMarkNo,
      geolocation: geolocation ?? this.geolocation,
      compassDegree: compassDegree ?? this.compassDegree,
      distanceToNextMarkMeter: distanceToNextMarkMeter ?? this.distanceToNextMarkMeter,
    );
  }

  // nullを許容する compassDegree と distanceToNextMarkMeter の上書き用 copyWith
  GameClientState copyWithNullableCompassDegreeAndDistanceToNextMarkMeter({
    double? compassDegree,
    double? distanceToNextMarkMeter,
  }) {
    return GameClientState(
      connected: connected,
      authed: authed,
      started: started,
      marks: marks,
      nextMarkNo: nextMarkNo,
      geolocation: geolocation,
      compassDegree: compassDegree,
      distanceToNextMarkMeter: distanceToNextMarkMeter,
    );
  }

  // 次のマークを取得するゲッター
  MarkGeolocation? get nextMark => marks?[nextMarkNo - 1];
}
