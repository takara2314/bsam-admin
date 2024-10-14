import 'package:bsam_admin/domain/athlete.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:flutter/material.dart';

// ゲームクライアントの状態を表す不変なクラス
@immutable
class GameClientState {
  final bool connected;
  final bool authed;
  final bool started;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final List<MarkGeolocation>? marks;
  final List<AthleteInfo>? athletes;

  const GameClientState({
    required this.connected,
    required this.authed,
    required this.started,
    required this.startedAt,
    required this.finishedAt,
    required this.marks,
    required this.athletes,
  });

  // 状態を更新するためのcopyWithメソッド
  GameClientState copyWith({
    bool? connected,
    bool? authed,
    bool? started,
    DateTime? startedAt,
    DateTime? finishedAt,
    List<MarkGeolocation>? marks,
    List<AthleteInfo>? athletes,
  }) {
    return GameClientState(
      connected: connected ?? this.connected,
      authed: authed ?? this.authed,
      started: started ?? this.started,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      marks: marks ?? this.marks,
      athletes: athletes ?? this.athletes,
    );
  }

  // nullを許容する raceStatus の上書き用 copyWith
  GameClientState copyWithNullableRaceStatus({
    bool? started,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return GameClientState(
      connected: connected,
      authed: authed,
      started: started ?? this.started,
      startedAt: startedAt,
      finishedAt: finishedAt,
      marks: marks,
      athletes: athletes,
    );
  }
}
