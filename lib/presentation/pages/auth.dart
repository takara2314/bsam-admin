import 'dart:async';
import 'package:bsam_admin/infrastructure/repository/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:bsam_admin/app/auth/auth.dart';
import 'package:bsam_admin/presentation/widgets/icon.dart';
import 'package:bsam_admin/presentation/widgets/text.dart';
import 'package:bsam_admin/provider.dart';
import 'package:bsam_admin/router.dart';
import 'package:permission_handler/permission_handler.dart';

enum ViewName {
  authing,
  noNetwork,
  serverError
}

class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenNotifier = ref.watch(tokenProvider.notifier);
    final viewName = useState(ViewName.authing);

    useEffect(() {
      () async {
        // 位置情報と通知が許可されていないなら、許可ページに推移する
        final locationStatus = await Permission.location.status;
        final notificationStatus = await Permission.notification.status;
        if (locationStatus != PermissionStatus.granted || notificationStatus != PermissionStatus.granted) {
          if (context.mounted) {
            context.go(checkPermissionPagePath);
          }
          return;
        }

        await loadToken(ref);

        // トークンが保存されていないなら、ログインページに推移する
        if (tokenNotifier.state == '') {
          if (context.mounted) {
            context.go(loginPagePath);
          }
          return;
        }

        // インターネットに接続されていないなら
        if (!(await InternetConnection().hasInternetAccess)) {
          viewName.value = ViewName.noNetwork;
          return;
        }

        // トークンを検証し、有効であればトークンを更新する
        verifyToken(tokenNotifier.state)
          .then((res) async {
            // トークンを更新し、ホームページに推移する
            saveToken(ref, res.token);
            if (context.mounted) {
              context.go(homePagePath);
            }
          })
          .catchError((error) {
            // サーバーに接続できない or タイムアウトなら、サーバーエラーと表示
            if (error is TimeoutException || error is TimeoutException) {
              viewName.value = ViewName.serverError;
              return;

            // タイムアウト以外のエラーは認証失敗とみなし、
            // ログインページに遷移する
            } else if (context.mounted) {
              context.go(loginPagePath);
            }
          });
      }();

      return () {};
    }, []);

    switch (viewName.value) {
      case ViewName.authing:
        return const Authing();
      case ViewName.noNetwork:
        return const NoNetwork();
      case ViewName.serverError:
        return const ServerError();
      default:
        return const Scaffold();
    }
  }
}

class Authing extends StatelessWidget {
  const Authing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: const AppIcon(
                size: 200
              )
            ),
            const NormalText('ログイン中...')
          ]
        )
      )
    );
  }
}

class NoNetwork extends StatelessWidget {
  const NoNetwork({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: const NoNetworkIcon(
                size: 200
              )
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: const Heading(
                'インターネットに接続されていません'
              )
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: const NormalText(
                'B-SAMは、インターネットを利用してサービスを提供します。',
                textAlign: TextAlign.center
              ),
            )
          ]
        )
      )
    );
  }
}

class ServerError extends StatelessWidget {
  const ServerError({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: const ErrorIcon(
                size: 200
              )
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: const Heading(
                'サーバーに接続できませんでした'
              )
            ),
            const NormalText('協会に連絡してください。')
          ]
        )
      )
    );
  }
}
