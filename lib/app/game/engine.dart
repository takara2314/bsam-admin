import 'dart:async';

import 'package:bsam_admin/app/game/client.dart';
import 'package:bsam_admin/app/game/state.dart';
import 'package:bsam_admin/app/game/websocket/receiver.dart';
import 'package:bsam_admin/app/game/websocket/sender.dart';
import 'package:bsam_admin/app/game/websocket/websocket.dart';
import 'package:bsam_admin/domain/judge.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:bsam_admin/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 位置情報の送信間隔
const positingGeolocationInterval = Duration(seconds: 1);
// マーク通過のクールタイム
const passingMarkCoolTime = Duration(seconds: 10);

// ゲームの主要なロジックを管理するクラス
class GameEngine {
  final StateNotifierProviderRef<GameClientNotifier, GameClientState> _ref;
  final GameClientNotifier _client;

  late final GameWebSocket ws;

  Future<void> Function(int)? _callbackOnPassedMark;
  Timer? _postingGeolocationTimer;

  DateTime? _lastPassedMarkTime;

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
  void handleDisconnected() {
    if (_postingGeolocationTimer != null) {
      _postingGeolocationTimer!.cancel();
    }
  }

  // 認証成功時の処理
  void handleAuthed() {
    _startPostingGeolocation();
  }

  // 認証失敗時の処理
  void handleUnauthed() {}

  // レース開始時の処理
  void handleStarted() {}

  // レース終了時の処理
  void handleFinished() {}

  // 位置情報変更時の処理
  void handleChangedGeolocation(GeolocationState geolocation) {
    // コンパス角と距離を更新
    // パフォーマンスの観点で、両方同時に更新するプラクティスを採用
    _client.setCompassDegreeAndDistanceToNextMark(
      _calcNextMarkCompassDeg(
        geolocation.position!.latitude,
        geolocation.position!.longitude,
        geolocation.position!.heading
      ),
      _calcNextMarkDistanceMeter(
        geolocation.position!.latitude,
        geolocation.position!.longitude
      )
    );

    // レースが開始されていないなら、マーク通過判定処理を行わない
    if (!_client.started) {
      return;
    }

    // 最終マーク通過時間から10秒経過しないなら、マーク通過判定処理を行わない
    if (_lastPassedMarkTime != null) {
      final afterPassingMarkCoolTime = _lastPassedMarkTime!.add(passingMarkCoolTime);
      if (DateTime.now().isBefore(afterPassingMarkCoolTime)) {
        return;
      }
    }

    // マークを通過したかどうかを判定
    if (_judgePassedMark(_client.distanceToNextMarkMeter)) {
      handlePassedMark(_client.nextMarkNo);
    }
  }

  // マーク通過時の処理
  // TODO: wantMarkCounts が1のときの処理も実装する
  Future<void> handlePassedMark(int passedMarkNo) async {
    _lastPassedMarkTime = DateTime.now();

    // 通過したことをアナウンスする
    if (_callbackOnPassedMark != null) {
      _callbackOnPassedMark!(passedMarkNo);
    }

    // 通過したことをサーバーに通知
    _client.engine.ws.sender.sendPassedMarkAction(PassedMarkActionMessage(
      passedMarkNo: passedMarkNo,
      passedAt: DateTime.now(),
    ));

    // 次のマークを設定
    final wantMarkCounts = _ref.read(wantMarkCountsProvider);
    _client.nextMarkNo = calcNextMarkNo(wantMarkCounts, passedMarkNo);
  }

  // 認証を試みる
  void tryAuth(token, deviceId, wantMarkCounts) {
    _client.engine.ws.sender.sendAuthAction(AuthActionMessage(
      token: token,
      deviceId: deviceId,
      wantMarkCounts: wantMarkCounts
    ));
  }

  // 位置情報を登録する
  void registerGeolocation(GeolocationState geolocation) {
    _client.geolocation = geolocation;
    handleChangedGeolocation(geolocation);
  }

  // マーク通過時のコールバックを登録する
  void registerCallbackOnPassedMark(Future<void> Function(int) callback) {
    _callbackOnPassedMark = callback;
  }

  // 位置情報の定期送信を開始する
  void _startPostingGeolocation() {
    if (_postingGeolocationTimer != null) {
      return;
    }

    _postingGeolocationTimer = Timer.periodic(positingGeolocationInterval, (_) {
      if (_client.geolocation?.position == null) {
        return;
      }

      _client.engine.ws.sender.sendPostGeolocationAction(
        PostGeolocationActionMessage(
          latitude: _client.geolocation!.position!.latitude,
          longitude: _client.geolocation!.position!.longitude,
          altitudeMeter: _client.geolocation!.position!.altitude,
          accuracyMeter: _client.geolocation!.position!.accuracy,
          altitudeAccuracyMeter: _client.geolocation!.position!.altitudeAccuracy,
          heading: _client.geolocation!.position!.heading,
          speedMeterPerSec: _client.geolocation!.position!.speed,
          recordedAt: DateTime.now(),
        )
      );
    });
  }

  // 次のマークまでの距離を計算する
  double? _calcNextMarkDistanceMeter(double lat, double lng) {
    if (_client.nextMark == null) {
      return null;
    }

    // ストアされていないマークは距離を計算しない
    if (!_client.nextMark!.stored) {
      return null;
    }

    return Geolocator.distanceBetween(
      lat,
      lng,
      _client.nextMark!.latitude,
      _client.nextMark!.longitude
    );
  }

  // 次のマークへの方位角を計算する
  double? _calcNextMarkCompassDeg(double lat, double lng, double heading) {
    if (_client.nextMark == null) {
      return null;
    }

    // ストアされていないマークは方位角を計算しない
    if (!_client.nextMark!.stored) {
      return null;
    }

    // 現在位置から次のマークまでの方位角を計算
    double bearingDeg = Geolocator.bearingBetween(
      lat,
      lng,
      _client.nextMark!.latitude,
      _client.nextMark!.longitude
    );

    // 現在の進行方向と目的地への方位角の差を計算
    double diff = bearingDeg - heading;

    // 差を-180度から180度の範囲に正規化
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    // 正規化された差を返す（これがコンパスに表示される角度）
    return diff;
  }

  // マークを通過したかどうかを判定する
  bool _judgePassedMark(double? distanceToNextMarkMeter) {
    if (distanceToNextMarkMeter == null) {
      return false;
    }

    return distanceToNextMarkMeter < passingDistanceMeter;
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

  void handleMarkGeolocations(MarkGeolocationsHandlerMessage msg) {
    debugPrint('---');
    for (var mark in msg.marks) {
      debugPrint('mark: ${mark.markNo}');
      debugPrint('- stored: ${mark.stored}');
      debugPrint('  latitude: ${mark.latitude}');
      debugPrint('  longitude: ${mark.longitude}');
    }
    debugPrint('---\n');

    _client.marks = msg.marks;
  }

  void handleManageRaceStatus(ManageRaceStatusHandlerMessage msg) {
    _client.started = msg.started;
    // レースがスタートしたなら
    if (msg.started) {
      handleStarted();
    } else {
      handleFinished();
    }
  }

  void handleManageNextMark(ManageNextMarkHandlerMessage msg) {
    _client.nextMarkNo = msg.nextMarkNo;
  }
}
