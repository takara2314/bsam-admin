import 'package:bsam_admin/components/pop_app_bar.dart';
import 'package:bsam_admin/pages/manage/marks_area.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:bsam_admin/constants/app_constants.dart';
import 'package:bsam_admin/models/athlete.dart';
import 'package:bsam_admin/models/mark.dart';
import 'package:bsam_admin/models/live_msg.dart';
import 'package:bsam_admin/providers.dart';
import 'package:bsam_admin/pages/manage/athletes_area.dart';
import 'package:bsam_admin/pages/manage/start_stop_button.dart';
import 'package:bsam_admin/utils/random.dart';
import 'package:bsam_admin/utils/websocket_url_validator.dart';
import 'package:bsam_admin/utils/reconnection_strategy.dart';

class Manage extends ConsumerStatefulWidget {
  const Manage({super.key, required this.assocId});

  final String assocId;

  @override
  ConsumerState<Manage> createState() => _Manage();
}

class _Manage extends ConsumerState<Manage> {
  late WebSocketChannel _channel;
  bool _disposed = false;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isConnecting = false;

  bool? _started;
  List<Athlete> _athletes = [];
  List<Mark> _marks = [];

  @override
  void initState() {
    super.initState();
    _connectWs();
  }

  @override
  void dispose() {
    _disposed = true;
    _closeWsConnection();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  void _closeWsConnection() {
    try {
      if (_isConnected) {
        _channel.sink.close(status.normalClosure);
        _isConnected = false;
      }
    } catch (e) {
      debugPrint('WebSocket切断エラー: $e');
    }
  }

  void _connectWs() {
    // 接続可能状態のチェック
    if (_disposed || !mounted || _isConnecting) {
      return;
    }

    // ネットワーク接続状態を確認
    final connectivity = ref.read(connectivityProvider);
    if (connectivity == ConnectivityResult.none) {
      debugPrint('No network connection, skipping WebSocket connection');
      _scheduleReconnect();
      return;
    }

    // 接続中なら一度閉じる
    _closeWsConnection();

    // サーバーURLの取得
    final serverUrl = ref.read(serverUrlProvider);

    // WebSocket URLの検証
    final validationResult = WebSocketUrlValidator.validate(
      serverUrl,
      'racing/${widget.assocId}',
    );

    if (!validationResult.isValid) {
      debugPrint(
        'WebSocket URL validation failed: ${validationResult.errorMessage}',
      );
      FirebaseCrashlytics.instance.recordError(
        Exception(validationResult.errorMessage),
        StackTrace.current,
        fatal: false,
        reason: 'WebSocket connection validation failed',
      );
      _scheduleReconnect();
      return;
    }

    final uri = validationResult.uri!;

    _isConnecting = true;

    try {
      _channel = IOWebSocketChannel.connect(
        uri,
        pingInterval: const Duration(seconds: 1),
      );

      _isConnected = true;

      _channel.stream.listen(
        (msg) {
          _handleWsMessage(msg);
        },
        onDone: () {
          _handleWsDisconnection();
        },
        onError: (error) {
          debugPrint('WebSocketエラー: $error');
          _isConnecting = false;
          // エラーを非致命的に記録
          // ネットワークエラーでアプリがクラッシュすることを防ぐ
          FirebaseCrashlytics.instance.recordError(
            error,
            StackTrace.current,
            fatal: false,
            reason: 'WebSocket connection error',
          );
          _handleWsDisconnection();
        },
      );

      if (_disposed || !mounted) {
        _isConnecting = false;
        return;
      }

      // 接続成功時はリトライカウンターをリセット
      // これにより、次回の切断時には再び短い遅延（1秒）から再接続を開始する
      _reconnectAttempts = 0;

      final token = ref.read(jwtProvider);
      _sendWsMessage({
        'type': 'auth',
        'token': token,
        'user_id': generateRandomStr(8),
        'role': 'manager',
      });
    } catch (e) {
      _isConnecting = false;
      debugPrint('WebSocket接続エラー: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        fatal: false,
        reason: 'WebSocket connection exception',
      );
      _scheduleReconnect();
    }
  }

  void _handleWsDisconnection() {
    if (_disposed) return;

    _isConnected = false;
    _isConnecting = false;
    debugPrint('WebSocket切断: 再接続をスケジュール');
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    // 再接続スケジュール可能状態のチェック
    if (_disposed || !mounted || _isConnecting) {
      return;
    }

    // 既存のタイマーをキャンセル（重複防止）
    _reconnectTimer?.cancel();

    // 指数バックオフによる遅延時間の計算
    final delaySeconds = ReconnectionStrategy.calculateDelaySeconds(
      _reconnectAttempts,
    );

    _reconnectAttempts++;

    debugPrint(
      'Scheduling WebSocket reconnect in $delaySeconds seconds '
      '(attempt $_reconnectAttempts)',
    );

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_disposed && mounted) {
        debugPrint('WebSocket再接続試行');
        _connectWs();
      }
    });
  }

  void _handleWsMessage(dynamic msg) {
    if (_disposed || !mounted) return;

    try {
      final body = json.decode(msg);

      switch (body['type']) {
        case 'start_race':
          debugPrint('start_race');
          _receiveStartRace(body);
          break;

        case 'live':
          debugPrint('live');
          _receiveLive(LiveMsg.fromJson(body));
          break;
      }
    } catch (e) {
      debugPrint('メッセージ処理エラー: $e');
    }
  }

  void _sendWsMessage(Map<String, dynamic> message) {
    if (_disposed || !mounted || !_isConnected) return;

    try {
      // チャネルの状態を確認
      // クローズ済みのチャネルへの送信を防ぐ
      if (_channel.closeCode != null) {
        debugPrint('WebSocket channel is closed, attempting reconnect');
        _handleWsDisconnection();
        return;
      }
      _channel.sink.add(json.encode(message));
    } catch (e) {
      debugPrint('メッセージ送信エラー: $e');
      // 送信エラーを非致命的に記録
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.current,
        fatal: false,
        reason: 'WebSocket message send error',
      );
      _handleWsDisconnection();
    }
  }

  void _receiveStartRace(dynamic msg) {
    if (_disposed || !mounted) return;

    try {
      setState(() {
        _started = msg['started'];
      });
    } catch (e) {
      debugPrint('スタート状態更新エラー: $e');
    }
  }

  void _receiveLive(LiveMsg msg) {
    if (_disposed || !mounted) return;

    try {
      setState(() {
        _athletes = msg.athletes!;
        _marks = msg.marks!;
      });
    } catch (e) {
      debugPrint('ライブデータ更新エラー: $e');
    }
  }

  void _startRace(bool started) {
    if (_disposed || !mounted) return;

    _sendWsMessage({'type': 'start', 'started': started});

    setState(() {
      _started = started;
    });
  }

  void _forcePassed(String userId, int nextMarkNo) {
    if (_disposed || !mounted) return;

    nextMarkNo = nextMarkNo % AppConstants.markNum + 1;
    _setNextMarkNo(userId, nextMarkNo);
  }

  void _cancelPassed(String userId, int nextMarkNo) {
    if (_disposed || !mounted) return;

    int previousMarkNo =
        nextMarkNo - 1 == 0 ? AppConstants.markNum : nextMarkNo - 1;
    _setNextMarkNo(userId, previousMarkNo);
  }

  void _setNextMarkNo(String userId, int nextMarkNo) {
    if (_disposed || !mounted) return;

    _sendWsMessage({
      'type': 'set_next_mark_no',
      'user_id': userId,
      'next_mark_no': nextMarkNo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PopAppBar(pageName: 'レース管理'),
      body: SingleChildScrollView(
        child: Center(
          child:
              (_started == null
                  ? const Text('読み込み中')
                  : Column(
                    children: [
                      StartStopButton(
                        started: _started!,
                        startRace: _startRace,
                      ),
                      MarksArea(
                        markNames: AppConstants.standardMarkNames,
                        marks: _marks,
                      ),
                      AthletesArea(
                        markNames: AppConstants.standardMarkNames,
                        athletes: _athletes,
                        forcePassed: _forcePassed,
                        cancelPassed: _cancelPassed,
                      ),
                    ],
                  )),
        ),
      ),
    );
  }
}
