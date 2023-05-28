import 'package:flutter/material.dart';

class StartStopButton extends StatelessWidget {
  const StartStopButton({
    Key? key,
    required this.started,
    required this.startRace
  }) : super(key: key);

  final bool started;
  final Function(bool) startRace;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (started
        ? ElevatedButton(
            child: const Text(
              'レースを終了する'
            ),
            onPressed: () => startRace(false)
          )
        : ElevatedButton(
            child: const Text(
              'レースを開始する'
            ),
            onPressed: () => startRace(true)
          )
      )
    );
  }
}
