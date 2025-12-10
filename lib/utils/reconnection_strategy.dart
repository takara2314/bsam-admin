/// WebSocket再接続戦略を管理するクラス
///
/// このクラスは指数バックオフアルゴリズムを使用して、
/// 再接続の遅延時間を計算する責務を持つ。
///
/// 指数バックオフにより、サーバーへの負荷を軽減しながら、
/// ネットワーク一時障害からの自動復旧を実現する。
class ReconnectionStrategy {
  /// 初回再接続の遅延時間（秒）
  static const int initialDelaySeconds = 1;

  /// 最大遅延時間（秒）
  /// これ以上遅延時間が増加しないように上限を設定
  static const int maxDelaySeconds = 10;

  /// 最大遅延に達するまでの試行回数
  /// この回数を超えると、常にmaxDelaySecondsが使用される
  static const int maxAttemptsBeforeMaxDelay = 3;

  /// 再接続の遅延時間を計算する
  ///
  /// 指数バックオフアルゴリズム：
  /// - 1回目: 1秒
  /// - 2回目: 2秒
  /// - 3回目: 4秒
  /// - 4回目以降: 10秒（上限）
  ///
  /// このパターンにより、一時的なネットワーク障害では素早く再接続し、
  /// 長期的な障害ではサーバー負荷を抑えることができる。
  ///
  /// [attemptCount] 再接続試行回数（0から始まる）
  /// 戻り値: 次回の再接続までの遅延時間（秒）
  static int calculateDelaySeconds(int attemptCount) {
    if (attemptCount < maxAttemptsBeforeMaxDelay) {
      // 指数バックオフ: 2の累乗で遅延時間を増加
      // attemptCount=0 -> 1秒
      // attemptCount=1 -> 2秒
      // attemptCount=2 -> 4秒
      final exponentialDelay = initialDelaySeconds << attemptCount;
      return exponentialDelay.clamp(initialDelaySeconds, maxDelaySeconds);
    }
    // 最大試行回数を超えた場合は、常に最大遅延時間を使用
    return maxDelaySeconds;
  }
}
