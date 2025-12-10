/// ネットワーク関連エラーの分類ユーティリティ
class ErrorClassifier {
  /// ネットワーク関連のエラーキーワード
  static const List<String> _networkErrorKeywords = [
    'WebSocket',
    'SocketException',
    'Connection',
    'Network',
    'TimeoutException',
    'HandshakeException',
  ];

  /// エラーがネットワーク関連かどうかを判定
  ///
  /// ネットワーク関連のエラーは非致命的として扱うべきものとして分類される。
  /// これにより、一時的なネットワーク障害でアプリがクラッシュすることを防ぐ。
  ///
  /// [error] 判定対象のエラーオブジェクト
  /// 戻り値: ネットワーク関連のエラーの場合true
  static bool isNetworkRelatedError(Object error) {
    final errorString = error.toString();
    return _networkErrorKeywords.any(
      (keyword) => errorString.contains(keyword),
    );
  }

  /// エラーが致命的かどうかを判定
  ///
  /// ネットワーク関連のエラーは非致命的、それ以外は致命的として扱う。
  ///
  /// [error] 判定対象のエラーオブジェクト
  /// 戻り値: 致命的なエラーの場合true
  static bool isFatalError(Object error) {
    return !isNetworkRelatedError(error);
  }
}
