import 'package:bsam_admin/domain/athlete.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:flutter/material.dart';

// ゲームクライアントの状態を表す不変なクラス
@immutable
class GameClientState {
  final bool connected;
  final bool authed;
  final bool started;
  final List<MarkGeolocation>? marks;
  final List<AthleteInfo>? athletes;

  const GameClientState({
    required this.connected,
    required this.authed,
    required this.started,
    required this.marks,
    required this.athletes,
  });

  // 状態を更新するためのcopyWithメソッド
  GameClientState copyWith({
    bool? connected,
    bool? authed,
    bool? started,
    List<MarkGeolocation>? marks,
    List<AthleteInfo>? athletes,
  }) {
    return GameClientState(
      connected: connected ?? this.connected,
      authed: authed ?? this.authed,
      started: started ?? this.started,
      marks: marks ?? this.marks,
      athletes: athletes ?? this.athletes,
    );
  }
}
