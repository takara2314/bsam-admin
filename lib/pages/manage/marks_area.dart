import 'package:flutter/material.dart';

import 'package:bsam_admin/models/mark.dart';
import 'package:bsam_admin/components/battery_and_acc.dart';

class MarksArea extends StatelessWidget {
  const MarksArea({
    super.key,
    required this.markNames,
    required this.marks
  });

  final Map<int, List<String>> markNames;
  final List<Mark> marks;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: width * 0.9,
      padding: const EdgeInsets.only(top: 20, left: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          for (final mark in marks)
            MarkItem(
              markNames: markNames,
              mark: mark
            )
        ]
      )
    );
  }
}

class MarkItem extends StatelessWidget {
  const MarkItem({
    super.key,
    required this.markNames,
    required this.mark
  });

  final Map<int, List<String>> markNames;
  final Mark mark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'images/icon_mark${mark.markNo}.png',
              width: 30
            )
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        '${markNames[mark.markNo]![0]}マーク',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      ),
                      Visibility(
                        visible: mark.userId == '' && mark.position!.lat != 0.0,
                        child: const Text(
                          '（切断）',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange
                          )
                        )
                      )
                    ]
                  )
                )
              ),
              Visibility(
                visible: mark.position!.lat != 0.0,
                child: BatteryAndAcc(
                  batteryLevel: mark.batteryLevel!,
                  acc: mark.position!.acc!
                )
              ),
              Visibility(
                visible: mark.userId == '' && mark.position!.lat == 0.0,
                child: const Text(
                  '設定されていません',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepOrange
                  )
                )
              )
            ]
          )
        ]
      )
    );
  }
}
