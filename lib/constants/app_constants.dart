/// アプリケーション全体で使用する定数
class AppConstants {
  // 協会名
  static const String assocName = 'セーリング伊勢';
  // レース名
  static const String raceName = '全国ハンザクラスブラインドセーリング大会';

  // マーク数
  static const int markNum = 3;

  // 標準マーク名
  static const Map<int, List<String>> standardMarkNames = {
    1: ['上', 'かみ', '①'],
    2: ['サイド', 'さいど', '②'],
    3: ['下', 'しも', '③']
  };

  // アップデート間隔（ミリ秒）
  static const int batteryUpdateInterval = 10000;
  static const int locationUpdateInterval = 1000;

  // WebSocket再接続間隔（秒）
  static const int wsReconnectInterval = 3;

  // 位置精度の閾値
  static const double locationAccuracyThreshold = 30.0;

  // インターネットに接続されていない場合のダイアログ表示
  static const String noConnectionDialogTitle = 'インターネットに接続されていません';
  static const String noConnectionDialogContent = 'B-SAMを利用するにはインターネットの接続が必要です。SIMカードの有効期限が切れていないか確認してください。';
}
