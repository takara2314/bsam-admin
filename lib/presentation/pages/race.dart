import 'package:bsam_admin/app/game/client.dart';
import 'package:bsam_admin/app/game/announcer.dart';
import 'package:bsam_admin/app/game/detail/hook.dart';
import 'package:bsam_admin/app/game/geolocation_register.dart';
import 'package:bsam_admin/app/voice/voice.dart';
import 'package:bsam_admin/app/wakelock/wakelock.dart';
import 'package:bsam_admin/domain/distance.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:bsam_admin/presentation/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_use/flutter_use.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';
import 'package:bsam_admin/app/jwt/jwt.dart';
import 'package:bsam_admin/main.dart';
import 'package:bsam_admin/presentation/widgets/compass.dart';
import 'package:bsam_admin/presentation/widgets/text.dart';
import 'package:bsam_admin/provider.dart';

const defaultWantMarkCounts = 3;
const compassEasingAnimationSpeed = Duration(milliseconds: 10);

class RacePage extends HookConsumerWidget {
  final String athleteId;

  const RacePage({
    required this.athleteId,
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

    // スリープしないようにする
    useWakelock();

    // 位置情報を取得する
    final geolocation = useGeolocation(
      locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    ));

    // アナウンスに使用するTTS
    final voice = useVoice(
      'ja-JP',
      0.6,
      1.0,
      1.0,
    );

    // アナウンスを行う
    final callbackOnPassedMark = useAnnouncer(
      context,
      ref,
      voice,
      gameState,
    );

    // 位置情報が更新されるたびに、ゲームクライアントに登録
    useGeolocationRegister(
      context,
      clientNotifier,
      geolocation,
    );

    // レースサーバーに接続する
    useEffect(() {
      // Futureを使用してビルド後にプロバイダーを更新
      Future(() {
        associationIdNotifier.state = jwt.associationId;
        deviceIdNotifier.state = athleteId;
        wantMarkCountsNotifier.state = defaultWantMarkCounts;

        clientNotifier.connect();
        clientNotifier.registerCallbackOnPassedMark(callbackOnPassedMark);
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final shouldPop = await showExitConfirmationDialog(context, clientNotifier);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: RaceAppBar(
          raceName: raceDetail.value?.name ?? '',
          preferredSize: const Size.fromHeight(72),
        ),
        body: Center(
          child: gameState.started
            ? RaceStarted(
              compassDegree: gameState.compassDegree,
              nextMarkNo: gameState.nextMarkNo,
              nextMarkName: getMarkLabel(
                wantMarkCountsNotifier.state,
                gameState.nextMarkNo
              ).name,
              distanceToNextMarkMeter: gameState.distanceToNextMarkMeter,
              geolocation: geolocation
            )
            : RaceWaiting(
              geolocation: geolocation
            )
        )
      )
    );
  }
}

Future<bool> showExitConfirmationDialog(BuildContext context, GameClientNotifier clientNotifier) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('レースを終了しますか？'),
        content: const Text('レースを終了すると、サーバーとの接続が切断されます。'),
        actions: <Widget>[
          TextButton(
            child: const Text('いいえ'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('はい'),
            onPressed: () {
              clientNotifier.disconnect();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  ) ?? false;
}

class RaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String raceName;

  const RaceAppBar({
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

class RaceWaiting extends StatelessWidget {
  final GeolocationState geolocation;

  const RaceWaiting({
    required this.geolocation,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: const AppIcon(
            size: 200
          )
        ),
        const NormalText('レース開始をお待ちください...'),
        RaceMarkSensorInfo(
          latitude: geolocation.position?.latitude ?? 0,
          longitude: geolocation.position?.longitude ?? 0,
          accuracyMeter: geolocation.position?.accuracy ?? 0,
          heading: geolocation.position?.heading ?? 0,
          compassDegree: 0,
          showingCompass: false
        )
      ]
    );
  }
}

class RaceStarted extends StatelessWidget {
  final double? compassDegree;
  final int nextMarkNo;
  final String nextMarkName;
  final double? distanceToNextMarkMeter;
  final GeolocationState geolocation;

  const RaceStarted({
    required this.compassDegree,
    required this.nextMarkNo,
    required this.nextMarkName,
    required this.distanceToNextMarkMeter,
    required this.geolocation,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RaceCompass(heading: compassDegree),
        RaceMarkDirectionInfo(
          nextMarkNo: nextMarkNo,
          nextMarkName: nextMarkName,
          distanceToNextMarkMeter: distanceToNextMarkMeter
        ),
        RaceMarkSensorInfo(
          latitude: geolocation.position?.latitude ?? 0,
          longitude: geolocation.position?.longitude ?? 0,
          accuracyMeter: geolocation.position?.accuracy ?? 0,
          heading: geolocation.position?.heading ?? 0,
          compassDegree: compassDegree
        )
      ]
    );
  }
}

class RaceCompass extends HookWidget {
  final double? heading;

  const RaceCompass({
    required this.heading,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final animatedHeading = useState<double>(0.0);

    useInterval(() {
      if (heading == null) {
        return;
      }
      animatedHeading.value += (heading! - animatedHeading.value) * 0.1;
    }, compassEasingAnimationSpeed);

    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: Compass(heading: animatedHeading.value)
      )
    );
  }
}

class RaceMarkDirectionInfo extends StatelessWidget {
  final int nextMarkNo;
  final String nextMarkName;
  final double? distanceToNextMarkMeter;

  const RaceMarkDirectionInfo({
    required this.nextMarkNo,
    required this.nextMarkName,
    required this.distanceToNextMarkMeter,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    String distanceToNextMarkMeterForLabel;
    if (distanceToNextMarkMeter != null) {
      distanceToNextMarkMeterForLabel = getAnnounceDistanceMeter(distanceToNextMarkMeter!).toString();
    } else {
      distanceToNextMarkMeterForLabel = '?';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaceMarkNoIcon(markNo: nextMarkNo),
              Heading('$nextMarkNameマーク', fontSize: 24)
            ]
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 7),
              child: Heading(
                '残り 約',
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                distanceToNextMarkMeterForLabel,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 7),
              child: Heading(
                'm',
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]
        ),
      ]
    );
  }
}

class RaceMarkNoIcon extends StatelessWidget {
  final int markNo;

  const RaceMarkNoIcon({
    required this.markNo,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(9999)
      ),
      child: Text(
        '$markNo',
        style: const TextStyle(
          color: Colors.white,
          fontSize: bodyHeadingSize,
          fontWeight: FontWeight.bold
        )
      )
    );
  }
}

class RaceMarkSensorInfo extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double accuracyMeter;
  final double heading;
  final double? compassDegree;
  final bool showingCompass;

  const RaceMarkSensorInfo({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    required this.heading,
    required this.compassDegree,
    this.showingCompass = true,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    String compassDegreeForLabel;
    if (compassDegree != null) {
      compassDegreeForLabel = '${compassDegree!.toStringAsFixed(2)}°';
    } else {
      compassDegreeForLabel = '?°';
    }

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(5),
        },
        children: [
          TableRow(
            children: [
              const RaceMarkSensorInfoLabelCell('緯度 / 経度'),
              RaceMarkSensorInfoValueCell(
                '${latitude.toStringAsFixed(6)} / ${longitude.toStringAsFixed(6)}'
              ),
            ],
          ),
          TableRow(
            children: [
              const RaceMarkSensorInfoLabelCell('位置情報の精度'),
              RaceMarkSensorInfoValueCell(
                '${accuracyMeter.toStringAsFixed(2)}m'
              ),
            ],
          ),
          TableRow(
            children: [
              const RaceMarkSensorInfoLabelCell('方向の角度'),
              RaceMarkSensorInfoValueCell(
                '${heading.toStringAsFixed(2)}°'
              ),
            ],
          ),
          if (showingCompass)
            TableRow(
              children: [
                const RaceMarkSensorInfoLabelCell('コンパスの角度'),
                RaceMarkSensorInfoValueCell(compassDegreeForLabel),
              ],
            )
        ]
      )
    );
  }
}

class RaceMarkSensorInfoLabelCell extends StatelessWidget {
  final String label;

  const RaceMarkSensorInfoLabelCell(
    this.label,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: NormalText(label)
    );
  }
}

class RaceMarkSensorInfoValueCell extends StatelessWidget {
  final String value;

  const RaceMarkSensorInfoValueCell(
    this.value,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: StrongText(value)
    );
  }
}
