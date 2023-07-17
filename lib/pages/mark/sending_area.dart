import 'package:flutter/material.dart';

class SendingArea extends StatelessWidget {
  const SendingArea({
    Key? key,
    required this.markNo,
    required this.markNames,
    required this.receivedInfoServer,
    required this.sentPosition
  }) : super(key: key);

  final int markNo;
  final Map<int, List<String>> markNames;
  final bool receivedInfoServer;
  final bool sentPosition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Text(
            '${markNames[markNo]![2]}${markNames[markNo]![0]}マーク',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            (sentPosition && receivedInfoServer) ? '送信中です' : '...',
            style: TextStyle(
              fontSize: 36,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            )
          )
        ],
      )
    );
  }
}
