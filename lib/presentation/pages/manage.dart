import 'package:bsam_admin/app/game/client.dart';
import 'package:bsam_admin/app/game/detail/hook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bsam_admin/app/jwt/jwt.dart';
import 'package:bsam_admin/main.dart';
import 'package:bsam_admin/provider.dart';
import 'package:bsam_admin/domain/manager.dart';

const defaultWantMarkCounts = 3;

class ManagePage extends HookConsumerWidget {
  const ManagePage({
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenNotifier = ref.watch(tokenProvider.notifier);
    final jwt = Jwt.fromToken(tokenNotifier.state);

    final associationIdNotifier = ref.watch(associationIdProvider.notifier);
    final deviceIdNotifier = ref.watch(deviceIdProvider.notifier);
    final wantMarkCountsNotifier = ref.watch(wantMarkCountsProvider.notifier);

    final clientNotifier = ref.watch(gameClientProvider.notifier);
    final gameState = ref.watch(gameClientProvider);

    final raceDetail = useRaceDetail(
      context,
      jwt.associationId,
      tokenNotifier.state,
    );

    // レースサーバーに接続する
    useEffect(() {
      // Futureを使用してビルド後にプロバイダーを更新
      Future(() {
        associationIdNotifier.state = jwt.associationId;
        deviceIdNotifier.state = createManagerDeviceId();
        wantMarkCountsNotifier.state = defaultWantMarkCounts;

        clientNotifier.connect();
      });

      return () {
        if (clientNotifier.connected) {
          // 非同期的にプロバイダーを変更
          Future.microtask(() {
            clientNotifier.disconnect();
          });
        }
      };
    }, []);

    return Scaffold(
      appBar: ManageAppBar(
        raceName: raceDetail.value?.name ?? '',
        preferredSize: const Size.fromHeight(72),
      ),
      body: Center(
        child: Text(gameState.connected ? '管理画面' : '接続中...')
      )
    );
  }
}

class ManageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String raceName;

  const ManageAppBar({
    required this.raceName,
    required this.preferredSize,
    super.key
  });

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: false,
      title: Text(
        raceName,
        style: const TextStyle(
          color: bodyTextColor,
          fontSize: bodyTextSize,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}
