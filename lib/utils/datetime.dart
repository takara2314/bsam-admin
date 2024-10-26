bool isToday(DateTime date) {
  final today = DateTime.now();

  return (
    date.year == today.year &&
    date.month == today.month &&
    date.day == today.day
  );
}

String _formatElapsedTime(Duration difference) {
  // 1分以内の場合は、 "n秒" と返す (nは整数)
  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}秒';
  }

  // 1時間以内の場合は、 "n分" と返す (nは整数)
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}分';
  }

  // 1日以内の場合は、 "n時間" と返す (nは整数)
  if (difference.inHours < 24) {
    return '${difference.inHours}時間';
  }

  // 1週間以内の場合は、 "n日" と返す (nは整数)
  if (difference.inDays < 7) {
    return '${difference.inDays}日';
  }

  // 1か月以内の場合は、 "n週間" と返す (nは整数)
  if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()}週間';
  }

  // 1年以内の場合は、 "nか月" と返す (nは整数)
  if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()}か月';
  }

  // それ以外の場合は、 "n年" と返す (nは整数)
  return '${(difference.inDays / 365).floor()}年';
}

// 現在時刻からどれぐらい経過したか返す関数
String formatElapsedTimeInJapanese(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  return _formatElapsedTime(difference);
}

// 現在時刻からどれぐらい経過したか返す関数 (最小は0秒前)
String formatElapsedTimeInJapaneseNotNegative(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  if (difference.inSeconds < 0) {
    return '0秒';
  }
  return _formatElapsedTime(difference);
}
