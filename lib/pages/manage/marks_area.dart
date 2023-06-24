import 'package:flutter/material.dart';

import 'package:bsam_admin/models/mark.dart';

class MarksArea extends StatelessWidget {
  const MarksArea({
    Key? key,
    required this.markNames,
    required this.marks
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final List<Mark> marks;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: width * 0.9,
      child: Column(
        children: [
          for (final mark in marks)
            Visibility(
              visible: markNames.containsKey(mark.markNo),
              child: MarkItem(
                markNames: markNames,
                mark: mark
              )
            )
        ]
      )
    );
  }
}

class MarkItem extends StatelessWidget {
  const MarkItem({
    Key? key,
    required this.markNames,
    required this.mark
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final Mark mark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 1
            )
          )
        ),
        child: Column(
          children: [
            MarkInfo(
              markNames: markNames,
              mark: mark
            )
          ]
        )
      )
    );
  }
}

class MarkInfo extends StatelessWidget {
  const MarkInfo({
    Key? key,
    required this.markNames,
    required this.mark
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final Mark mark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${markNames[mark.markNo]![0]}マーク',
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold
          )
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'バッテリー: ${mark.batteryLevel}%',
            style: const TextStyle(
              fontSize: 16
            )
          )
        )
      ]
    );
  }
}
