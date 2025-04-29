import 'package:flutter/material.dart';

class DebugArea extends StatelessWidget {
  const DebugArea({
    super.key,
    required this.manual,
    required this.latitude,
    required this.longitude,
    required this.accuracy
  });

  final bool manual;
  final double latitude;
  final double longitude;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          !manual ? '緯度 / 経度' : '緯度 / 経度 （手動設定）',
          style: Theme.of(context).textTheme.displaySmall
        ),
        Text(
          '${latitude.toStringAsFixed(6)} / ${longitude.toStringAsFixed(6)}'
        ),
        Text(
          '位置情報の精度',
          style: Theme.of(context).textTheme.displaySmall
        ),
        Text(
          !manual ? '$accuracy m' : '---'
        )
      ]
    );
  }
}
