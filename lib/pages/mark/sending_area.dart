import 'package:flutter/material.dart';

class SendingArea extends StatelessWidget {
  const SendingArea({
    Key? key,
    required this.markNo
  }) : super(key: key);

  final int markNo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Text(
            'マーク $markNo',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            '送信中です',
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
