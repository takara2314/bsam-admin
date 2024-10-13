import 'package:bsam_admin/presentation/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bsam_admin/presentation/widgets/icon.dart';
import 'package:bsam_admin/presentation/widgets/text.dart';
import 'package:bsam_admin/router.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermissionPage extends HookConsumerWidget {
  const CheckPermissionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    requestPermission() async {
      final locationStatus = await Permission.location.request();
      final notificationStatus = await Permission.notification.request();
      if (
        locationStatus == PermissionStatus.permanentlyDenied ||
        notificationStatus == PermissionStatus.permanentlyDenied
      ) {
        await openAppSettings();
      }

      // 位置情報と通知が許可されているなら、認証ページに推移する
      if (
        locationStatus == PermissionStatus.granted &&
        notificationStatus == PermissionStatus.granted &&
        context.mounted
      ) {
        context.go(authPagePath);
      }
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: const AppIcon(
                  size: 200
                )
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: const Heading(
                  '位置情報と通知を許可してください'
                )
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: const NormalText(
                  'B-SAMは位置情報を利用して、セーリングのナビゲーションを行います。また、画面を閉じても処理を続行するため、通知も許可してください。',
                  textAlign: TextAlign.center
                ),
              ),
              PrimaryButton(
                label: 'はい',
                onPressed: requestPermission,
              )
            ]
          )
        )
      )
    );
  }
}
