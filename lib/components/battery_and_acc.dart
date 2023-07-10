import 'package:flutter/material.dart';

class BatteryAndAcc extends StatelessWidget {
  const BatteryAndAcc({
    Key? key,
    required this.batteryLevel,
    required this.acc
  }) : super(key: key);

  final int batteryLevel;
  final double acc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            const Text(
              'バッテリー: ',
              style: TextStyle(fontSize: 12, color: Colors.grey)
            ),
            Text(
              '$batteryLevel%',
              style: TextStyle(
                fontSize: 12,
                color: batteryLevel < 20 ? Colors.deepOrange : Colors.black
              )
            )
          ]
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              const Text(
                '精度: ',
                style: TextStyle(fontSize: 12, color: Colors.grey)
              ),
              Text(
                '${acc.toStringAsFixed(2)}m',
                style: TextStyle(
                  fontSize: 12,
                  color: acc > 10.0 ? Colors.deepOrange : Colors.black
                )
              )
            ]
          )
        )
      ]
    );
  }
}
