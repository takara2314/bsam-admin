import 'dart:convert';

import 'package:bsam_admin/app/game/client.dart';
import 'package:bsam_admin/domain/athlete.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:flutter/material.dart';

// WebSocketハンドラーのタイプ定数
const handlerTypeConnectResult = 'connect_result';
const handlerTypeAuthResult = 'auth_result';
const handlerTypeParticipantsInfo = 'participants_info';
const handlerTypeManageRaceStatus = 'manage_race_status';

// WebSocketからのメッセージを受信し処理するクラス
class GameWebSocketReceiver {
  final GameClientNotifier _client;

  GameWebSocketReceiver(this._client);

  // 受信したペイロードを適切なハンドラーに振り分ける
  void handlePayload(dynamic payload) {
    final msg = json.decode(payload);

    switch (msg['type']) {
      case handlerTypeConnectResult:
        final parsed = ConnectResultHandlerMessage.fromJson(msg);
        _client.engine.handleConnectResult(parsed);
        break;

      case handlerTypeAuthResult:
        final parsed = AuthResultHandlerMessage.fromJson(msg);
        _client.engine.handleAuthResult(parsed);
        break;

      case handlerTypeManageRaceStatus:
        final parsed = ManageRaceStatusHandlerMessage.fromJson(msg);
        _client.engine.handleManageRaceStatus(parsed);
        break;

      case handlerTypeParticipantsInfo:
        final parsed = ParticipantsInfoHandlerMessage.fromJson(msg);
        _client.engine.handleParticipantsInfo(parsed);
        break;

      default:
        debugPrint('Unknown message type: ${msg['type']}');
    }
  }
}

class ConnectResultHandlerMessage {
  final String messageType;
  final bool ok;
  final String hubId;

  ConnectResultHandlerMessage({
    required this.messageType,
    required this.ok,
    required this.hubId,
  });

  factory ConnectResultHandlerMessage.fromJson(Map<String, dynamic> json) {
    return ConnectResultHandlerMessage(
      messageType: json['type'] as String,
      ok: json['ok'] as bool,
      hubId: json['hub_id'] as String,
    );
  }
}

class AuthResultHandlerMessage {
  final String messageType;
  final bool ok;
  final String deviceId;
  final String role;
  final int markNo;
  final bool authed;
  final String message;

  AuthResultHandlerMessage({
    required this.messageType,
    required this.ok,
    required this.deviceId,
    required this.role,
    required this.markNo,
    required this.authed,
    required this.message,
  });

  factory AuthResultHandlerMessage.fromJson(Map<String, dynamic> json) {
    return AuthResultHandlerMessage(
      messageType: json['type'] as String,
      ok: json['ok'] as bool,
      deviceId: json['device_id'] as String,
      role: json['role'] as String,
      markNo: json['mark_no'] as int,
      authed: json['authed'] as bool,
      message: json['message'] as String,
    );
  }
}

class ParticipantsInfoHandlerMessage {
  final String messageType;
  final int markCounts;
  final List<MarkGeolocation> marks;
  final List<AthleteInfo> athletes;

  ParticipantsInfoHandlerMessage({
    required this.messageType,
    required this.markCounts,
    required this.marks,
    required this.athletes,
  });

  factory ParticipantsInfoHandlerMessage.fromJson(Map<String, dynamic> json) {
    return ParticipantsInfoHandlerMessage(
      messageType: json['type'] as String,
      markCounts: json['mark_counts'] as int,
      marks: (json['marks'] as List<dynamic>)
          .map((e) => MarkGeolocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      athletes: (json['athletes'] as List<dynamic>)
          .map((e) => AthleteInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ManageRaceStatusHandlerMessage {
  final String messageType;
  final bool started;
  final DateTime startedAt;
  final DateTime finishedAt;

  ManageRaceStatusHandlerMessage({
    required this.messageType,
    required this.started,
    required this.startedAt,
    required this.finishedAt,
  });

  factory ManageRaceStatusHandlerMessage.fromJson(Map<String, dynamic> json) {
    return ManageRaceStatusHandlerMessage(
      messageType: json['type'] as String,
      started: json['started'] as bool,
      startedAt: DateTime.parse(json['started_at'] as String),
      finishedAt: DateTime.parse(json['finished_at'] as String),
    );
  }
}
