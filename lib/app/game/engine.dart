import 'package:bsam_admin/app/game/client.dart';
import 'package:bsam_admin/app/game/state.dart';
import 'package:bsam_admin/app/game/websocket/receiver.dart';
import 'package:bsam_admin/app/game/websocket/sender.dart';
import 'package:bsam_admin/app/game/websocket/websocket.dart';
import 'package:bsam_admin/provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ゲームの主要なロジックを管理するクラス
class GameEngine {
  final StateNotifierProviderRef<GameClientNotifier, GameClientState> _ref;
  final GameClientNotifier _client;

  late final GameWebSocket ws;

  GameEngine(this._ref, this._client) {
    ws = GameWebSocket(_ref, _client);
  }

  // 接続成功時の処理
  void handleConnected() {
    final token = _ref.read(tokenProvider);
    final deviceId = _ref.read(deviceIdProvider);
    final wantMarkCounts = _ref.read(wantMarkCountsProvider);

    tryAuth(token, deviceId, wantMarkCounts);
  }

  // 切断時の処理
  void handleDisconnected() {}

  // 認証成功時の処理
  void handleAuthed() {}

  // 認証失敗時の処理
  void handleUnauthed() {}

  // レース開始時の処理
  void handleStarted() {}

  // レース終了時の処理
  void handleFinished() {}

  // 認証を試みる
  void tryAuth(token, deviceId, wantMarkCounts) {
    _client.engine.ws.sender.sendAuthAction(AuthActionMessage(
      token: token,
      deviceId: deviceId,
      wantMarkCounts: wantMarkCounts
    ));
  }

  // レースの開始状況を管理する
  void manageRaceStatus(bool started) {
    _client.engine.ws.sender.sendManageRaceStatusAction(ManageRaceStatusActionMessage(
      started: started,
      startedAt: _client.startedAt,
      finishedAt: _client.finishedAt
    ));
  }

  // そのデバイスを強制的に特定のマークに案内する
  void manageNextMark(String targetDeviceId, int nextMarkNo) {
    _client.engine.ws.sender.sendManageNextMarkAction(ManageNextMarkActionMessage(
      targetDeviceId: targetDeviceId,
      nextMarkNo: nextMarkNo,
    ));
  }

  void handleConnectResult(ConnectResultHandlerMessage msg) {}

  void handleAuthResult(AuthResultHandlerMessage msg) {
    _client.authed = msg.authed;
    // 認証が成功したなら
    if (msg.authed) {
      handleAuthed();
    } else {
      handleUnauthed();
    }
  }

  void handleParticipantsInfo(ParticipantsInfoHandlerMessage msg) {
    debugPrint('---');
    for (var mark in msg.marks) {
      debugPrint('mark: ${mark.markNo}');
      debugPrint('- stored: ${mark.stored}');
      debugPrint('  latitude: ${mark.latitude}');
      debugPrint('  longitude: ${mark.longitude}');
    }
    debugPrint('---\n');

    _client.marks = msg.marks;
    _client.athletes = msg.athletes;
  }

  void handleManageRaceStatus(ManageRaceStatusHandlerMessage msg) {
    _client.setRaceStatus(
      msg.started,
      msg.startedAt,
      msg.finishedAt
    );

    // レースがスタートしたなら
    if (msg.started) {
      handleStarted();
    } else {
      handleFinished();
    }
  }
}
