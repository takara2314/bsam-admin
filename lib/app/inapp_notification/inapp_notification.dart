import 'package:bsam_admin/main.dart';
import 'package:bsam_admin/presentation/widgets/text.dart';
import 'package:flutter/material.dart';

void hideNotification(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

void showNotificationNormal(
  BuildContext context,
  String message,
  {int durationSec = 3}
) {
  // 既存の SnackBar を即座に非表示にする
  hideNotification(context);

  ScaffoldMessenger.of(context).showSnackBar(
    NotificationSnackBar(
      message,
      secondaryColor,
      durationSec,
    ),
  );
}

void showNotificationWarning(
  BuildContext context,
  String message,
  {int durationSec = 3}
) {
  // 既存の SnackBar を即座に非表示にする
  hideNotification(context);

  ScaffoldMessenger.of(context).showSnackBar(
    NotificationSnackBar(
      message,
      Colors.orange,
      durationSec,
    ),
  );
}

void showNotificationError(
  BuildContext context,
  String message,
  {int durationSec = 3}
) {
  // 既存の SnackBar を即座に非表示にする
  hideNotification(context);

  ScaffoldMessenger.of(context).showSnackBar(
    NotificationSnackBar(
      message,
      Colors.red,
      durationSec,
    ),
  );
}

class NotificationSnackBar extends SnackBar {
  NotificationSnackBar(
    String message,
    Color backgroundColor,
    int durationSec, {super.key}
  ) : super(
    content: NormalText(
      message,
      color: Colors.white,
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: durationSec),
    backgroundColor: backgroundColor,
  );
}
