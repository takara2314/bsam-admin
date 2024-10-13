import 'dart:math';

int getRandomInt(int min, int max) {
  final random = Random();
  return min + random.nextInt(max - min + 1);
}
