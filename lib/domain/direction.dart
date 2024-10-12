// コンパス角度 (-180 ~ 180) から方向名を取得
String getDirectionName(double compassDegree) {
  if (compassDegree >= -15 && compassDegree < 15) {
    return '前';
  }
  if (compassDegree >= 15 && compassDegree < 60) {
    return 'やや右前';
  }
  if (compassDegree >= 60 && compassDegree < 120) {
    return '右';
  }
  if (compassDegree >= 120 && compassDegree < 150) {
    return 'やや右後ろ';
  }
  if (compassDegree >= 150 || compassDegree < -150) {
    return '後ろ';
  }
  if (compassDegree >= -150 && compassDegree < -120) {
    return 'やや左後ろ';
  }
  if (compassDegree >= -120 && compassDegree < -60) {
    return '左';
  }
  if (compassDegree >= -60 && compassDegree < -15) {
    return 'やや左前';
  }

  return '';
}
