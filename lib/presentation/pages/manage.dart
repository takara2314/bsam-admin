import 'package:bsam_admin/app/game/client.dart';
import 'package:bsam_admin/app/game/detail/hook.dart';
import 'package:bsam_admin/domain/athlete.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:bsam_admin/presentation/widgets/button.dart';
import 'package:bsam_admin/presentation/widgets/icon.dart';
import 'package:bsam_admin/presentation/widgets/text.dart';
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
      body:
        gameState.marks != null && gameState.athletes != null
          ? ManageViewAfterReceivedInfo(
              wantMarkCounts: wantMarkCountsNotifier.state,
            )
          : const ManageViewBeforeReceivedInfo()
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

class ManageViewBeforeReceivedInfo extends HookConsumerWidget {
  const ManageViewBeforeReceivedInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
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
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: const NormalText(
              'サーバーから情報を取得しています...',
              textAlign: TextAlign.center
            ),
          )
        ]
      )
    );
  }
}

class ManageViewAfterReceivedInfo extends HookConsumerWidget {
  final int wantMarkCounts;

  const ManageViewAfterReceivedInfo({
    required this.wantMarkCounts,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientNotifier = ref.watch(gameClientProvider.notifier);
    final gameState = ref.watch(gameClientProvider);

    return Column(
      children: [
        ManageRaceStartButton(
          started: gameState.started,
          onPressed: () {
            clientNotifier.manageRaceStatus(!gameState.started);
          },
        ),
        ManageMarksArea(
          wantMarkCounts: wantMarkCounts,
          markGeolocations: gameState.marks!,
        ),
      ],
    );
  }
}

class ManageRaceStartButton extends HookConsumerWidget {
  final bool started;
  final void Function() onPressed;

  const ManageRaceStartButton({
    required this.started,
    required this.onPressed,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(
        left: 30,
        right: 30,
        bottom: 20,
      ),
      child: PrimaryButton(
        label: started ? 'レースを終了する' : 'レースを開始する',
        onPressed: onPressed
      )
    );
  }
}

class ManageMarksArea extends StatelessWidget {
  final int wantMarkCounts;
  final List<MarkGeolocation> markGeolocations;

  const ManageMarksArea({
    required this.wantMarkCounts,
    required this.markGeolocations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 10,
        left: 30,
        right: 30,
      ),
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 1; i <= wantMarkCounts; i++) ...[
            ManageMark(
              markNo: i,
              markGeolocation: markGeolocations[i - 1],
            ),
            if (i != wantMarkCounts)
              const Divider(
                height: 1,
                color: bodyTextColor,
              ),
          ]
        ]
      ),
    );
  }
}

class ManageMark extends StatelessWidget {
  final int markNo;
  final MarkGeolocation markGeolocation;

  const ManageMark({
    required this.markNo,
    required this.markGeolocation,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final markName = markLabels[defaultWantMarkCounts]![markNo - 1].name;

    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
        bottom: 5,
      ),
      child: Column(
        children: [
          Heading(
            '$markNameマーク',
          )
        ],
      )
    );
  }
}

// class ManageAthletesArea extends HookConsumerWidget {
//   const ManageAthletesArea({super.key});
// }
