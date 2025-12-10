/// WebSocket URL検証の結果を表すクラス
class ValidationResult {
  final bool isValid;
  final Uri? uri;
  final String? errorMessage;

  const ValidationResult._({
    required this.isValid,
    this.uri,
    this.errorMessage,
  });

  /// 検証成功の結果を生成
  factory ValidationResult.success(Uri uri) {
    return ValidationResult._(isValid: true, uri: uri);
  }

  /// 検証失敗の結果を生成
  factory ValidationResult.error(String message) {
    return ValidationResult._(isValid: false, errorMessage: message);
  }
}

/// WebSocket URLのバリデーションを行うクラス
///
/// このクラスは、WebSocket接続前にURLの妥当性を検証する責務を持つ。
/// 検証項目：
/// - URLの存在チェック
/// - URI構文の検証
/// - ポート番号の検証（ポート0の検出）
/// - スキームの検証（ws/wss）
class WebSocketUrlValidator {
  /// WebSocket URLを検証する
  ///
  /// [baseUrl] 接続先のベースURL
  /// [path] エンドポイントのパス
  /// 戻り値: 検証結果（成功時はURI、失敗時はエラーメッセージ）
  static ValidationResult validate(String? baseUrl, String path) {
    // URLの存在チェック
    if (baseUrl == null || baseUrl.isEmpty) {
      return ValidationResult.error('Server URL is not configured');
    }

    // URI構文の検証
    Uri uri;
    try {
      uri = Uri.parse('$baseUrl/$path');
    } catch (e) {
      return ValidationResult.error('Failed to parse URL: $e');
    }

    // ポート番号の検証
    // ポート0は無効なポート番号であり、Crashlyticsで検出された問題の一つ
    if (uri.hasPort && uri.port == 0) {
      return ValidationResult.error(
        'Invalid port number: 0. Port must be between 1 and 65535.',
      );
    }

    // スキームの検証
    // WebSocket接続はws（非暗号化）またはwss（暗号化）のみ有効
    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      return ValidationResult.error(
        'Invalid WebSocket scheme: ${uri.scheme}. '
        'Expected "ws" or "wss".',
      );
    }

    // ホスト名の検証
    if (uri.host.isEmpty) {
      return ValidationResult.error('Invalid host name: host is empty');
    }

    return ValidationResult.success(uri);
  }
}
