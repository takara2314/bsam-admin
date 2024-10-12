import 'package:bsam_admin/app/game/client.dart';
import 'package:bsam_admin/app/game/state.dart';
import 'package:bsam_admin/app/game/websocket/receiver.dart';
import 'package:bsam_admin/app/game/websocket/sender.dart';
import 'package:bsam_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

// WebSocketの接続を維持するためのping間隔
const pingInterval = Duration(seconds: 1);
// WebSocket接続をリトライする時間
const reconnectInterval = Duration(seconds: 1);

// WebSocket通信を管理するクラス
class GameWebSocket {
  final StateNotifierProviderRef<GameClientNotifier, GameClientState> _ref;
  final GameClientNotifier _client;

  final GameWebSocketReceiver receiver;
  final GameWebSocketSender sender;

  late IOWebSocketChannel conn;
  bool connWorking = false;
  bool _allowReconnect = true;

  GameWebSocket(this._ref, this._client)
    : receiver = GameWebSocketReceiver(_client),
      sender = GameWebSocketSender(_client);

  // WebSocket接続を確立する
  void connect() {
    connWorking = true;
    final associationId = _ref.read(associationIdProvider);

    final url = Uri.parse(
      '$gameServerBaseUrlWs/$associationId'
    );

    conn = IOWebSocketChannel.connect(
      url,
      pingInterval: pingInterval
    );

    conn.stream.listen(
      (dynamic payload) {
        // 初めてのコネクション設立なら
        if (!_client.connected) {
          _client.connected = true;
          _client.engine.handleConnected();
        }
        receiver.handlePayload(payload);
      },
      onDone: () async {
        connWorking = false;
        _client.connected = false;
        if (_allowReconnect) {
          debugPrint('reconnect...');
          await Future.delayed(reconnectInterval);
          if (!connWorking) {
            connect();
          }
        }
      },
      onError: (error) async {
        connWorking = false;
        _client.connected = false;
        if (_allowReconnect) {
          debugPrint('reconnect... (with error: $error)');
          await Future.delayed(reconnectInterval);
          if (!connWorking) {
            connect();
          }
        }
      }
    );
  }

  // WebSocket接続を切断する
  void disconnect() {
    _allowReconnect = false;
    _client.engine.handleDisconnected();
    conn.sink.close(status.normalClosure);
  }

  // WebSocketでメッセージを送信する
  bool send(String payload) {
    if (!_client.connected) {
      return false;
    }
    conn.sink.add(payload);
    return true;
  }
}
