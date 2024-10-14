import 'dart:convert';

import 'package:bsam_admin/app/game/client.dart';

// WebSocketアクションのタイプ定数
const actionTypeAuth = 'auth';
const actionTypeManageRaceStatus = 'manage_race_status';
const actionTypeManageNextMark = 'manage_next_mark';

// WebSocketでメッセージを送信するクラス
class GameWebSocketSender {
  final GameClientNotifier _client;

  GameWebSocketSender(this._client);

  // 認証アクションを送信する
  bool sendAuthAction(AuthActionMessage msg) {
    return _client.engine.ws.send(msg.toJsonString());
  }

  // レースの開始状況を管理するアクションを送信する
  bool sendManageRaceStatusAction(ManageRaceStatusActionMessage msg) {
    return _client.engine.ws.send(msg.toJsonString());
  }

  // 次のマーク管理アクションを送信する
  bool sendManageNextMarkAction(ManageNextMarkActionMessage msg) {
    return _client.engine.ws.send(msg.toJsonString());
  }
}

class AuthActionMessage {
  final String type;
  final String token;
  final String deviceId;
  final int wantMarkCounts;

  AuthActionMessage({
    this.type = actionTypeAuth,
    required this.token,
    required this.deviceId,
    required this.wantMarkCounts,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'token': token,
    'device_id': deviceId,
    'want_mark_counts': wantMarkCounts,
  };

  String toJsonString() => jsonEncode(toJson());
}

class ManageRaceStatusActionMessage {
  final String type;
  final bool started;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  ManageRaceStatusActionMessage({
    this.type = actionTypeManageRaceStatus,
    required this.started,
    this.startedAt,
    this.finishedAt,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'started': started,
    'started_at': startedAt?.toIso8601String(),
    'finished_at': finishedAt?.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());
}

class ManageNextMarkActionMessage {
  final String type;
  final String targetDeviceId;
  final int nextMarkNo;

  ManageNextMarkActionMessage({
    this.type = actionTypeManageNextMark,
    required this.targetDeviceId,
    required this.nextMarkNo,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'target_device_id': targetDeviceId,
    'next_mark_no': nextMarkNo,
  };

  String toJsonString() => jsonEncode(toJson());
}
