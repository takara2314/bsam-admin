import 'package:bsam_admin/app/game/detail/hook.dart';
import 'package:bsam_admin/app/game/mark/marking.dart';
import 'package:bsam_admin/domain/mark.dart';
import 'package:bsam_admin/presentation/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bsam_admin/app/jwt/jwt.dart';
import 'package:bsam_admin/main.dart';
import 'package:bsam_admin/provider.dart';

const defaultWantMarkCounts = 3;

class MarkPage extends HookConsumerWidget {
  final int markNo;

  const MarkPage({
    required this.markNo,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenNotifier = ref.watch(tokenProvider.notifier);
    final jwt = Jwt.fromToken(tokenNotifier.state);

    final raceDetail = useRaceDetail(
      context,
      jwt.associationId,
      tokenNotifier.state,
    );

    // 位置情報を取得する (表示用)
    final geolocation = useGeolocation(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      )
    );

    // フォアグラウンドで位置情報を取得・送信する
    final marking = useMarking(
      tokenNotifier.state,
      markNo,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final shouldPop = await showExitConfirmationDialog(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: MarkAppBar(
          raceName: raceDetail.value?.name ?? '',
          preferredSize: const Size.fromHeight(72),
        ),
        body: Center(
          child: Column(
            children: [
              RaceMarkDirectionInfo(markNo: markNo),
              MarkSensorAndServerInfo(
                latitude: geolocation.position?.latitude ?? 0,
                longitude: geolocation.position?.longitude ?? 0,
                accuracyMeter: geolocation.position?.accuracy ?? 0,
                isLocationSent: marking.isLocationSent.value,
              )
            ]
          )
        )
      )
    );
  }
}

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('マーキングを終了しますか？'),
        content: const Text('マーキングを終了すると、選手用アプリで最後のマーク位置でアナウンスが行われます。'),
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
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  ) ?? false;
}

class MarkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String raceName;

  const MarkAppBar({
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

class RaceMarkNoIcon extends StatelessWidget {
  final int markNo;

  const RaceMarkNoIcon({
    required this.markNo,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(9999)
      ),
      child: Text(
        '$markNo',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 72,
          fontWeight: FontWeight.bold
        )
      )
    );
  }
}

class RaceMarkDirectionInfo extends StatelessWidget {
  final int markNo;

  const RaceMarkDirectionInfo({
    required this.markNo,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final markName = markLabels[defaultWantMarkCounts]![markNo - 1].name;
    return Column(
      children: [
        RaceMarkNoIcon(markNo: markNo),
        Heading('$markNameマーク', fontSize: 24)
      ]
    );
  }
}

class MarkSensorAndServerInfo extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double accuracyMeter;
  final bool isLocationSent;

  const MarkSensorAndServerInfo({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    required this.isLocationSent,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          MarkSensorInfoArea(
            latitude: latitude,
            longitude: longitude,
            accuracyMeter: accuracyMeter,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: NormalText(
              isLocationSent
                ? 'サーバーに位置情報を送信できました'
                : 'サーバーに位置情報を送信中...'
            )
          )
        ]
      )
    );
  }
}

class MarkSensorInfoArea extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double accuracyMeter;

  const MarkSensorInfoArea({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Table(
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
      ]
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
