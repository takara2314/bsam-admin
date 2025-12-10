import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocketチャネルの状態を表すクラス
///
/// このクラスは、WebSocketの現在の状態を型安全に表現し、
/// 送信可能かどうかの判定を一元管理する責務を持つ。
class WebSocketChannelState {
  /// チャネルが完全にクローズされているかどうか
  final bool isClosed;

  /// クローズコード（クローズされている場合）
  final int? closeCode;

  /// クローズ理由の説明文
  final String? closeReason;

  const WebSocketChannelState({
    required this.isClosed,
    this.closeCode,
    this.closeReason,
  });

  /// WebSocketチャネルから状態を取得する
  ///
  /// [channel] 状態を確認するWebSocketチャネル
  /// [isMarkedClosed] サービス側でクローズ済みとマークされているか
  /// 戻り値: チャネルの現在の状態
  factory WebSocketChannelState.fromChannel(
    WebSocketChannel channel,
    bool isMarkedClosed,
  ) {
    final closeCode = channel.closeCode;
    return WebSocketChannelState(
      isClosed: isMarkedClosed || closeCode != null,
      closeCode: closeCode,
      closeReason:
          closeCode != null ? 'WebSocket closed with code: $closeCode' : null,
    );
  }

  /// メッセージを送信可能かどうかを判定
  ///
  /// クローズされているチャネルへの送信は例外を引き起こすため、
  /// 送信前に必ずこのメソッドで確認すべき。
  ///
  /// 戻り値: 送信可能な場合true
  bool get canSend => !isClosed;

  /// デバッグ用の状態説明文を生成
  String get statusDescription {
    if (!isClosed) {
      return 'Connected';
    }
    if (closeReason != null) {
      return 'Closed: $closeReason';
    }
    return 'Closed';
  }
}
