import 'dart:math';

// 実数を文字列にする関数
String doubleToString(double value, {int decimalPoint = 2}) {
  if (isInt(value, decimalPoint)) {
    return value.toInt().toString();
  }
  return value.toString();
}

bool isInt(double value, int decimalPoint) {
  final multiplier = pow(10, decimalPoint);
  return (value * multiplier).round() / multiplier == value.round();
}
