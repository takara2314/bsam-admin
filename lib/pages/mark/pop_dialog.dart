import 'package:flutter/material.dart';

void isPopDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("本当に戻りますか？"),
        content: const Text("レースの真っ最中です。前の画面に戻るとブイのマーキングを終了することになります。"),
        actions: <Widget>[
          // ボタン領域
          TextButton(
            child: const Text("いいえ"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("はい"),
            onPressed: () {
              int count = 0;
              Navigator.popUntil(context, (_) => count++ >= 2);
            }
          ),
        ],
      );
    },
  );
}
