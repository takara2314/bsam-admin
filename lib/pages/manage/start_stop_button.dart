import 'package:flutter/material.dart';

class StartStopButton extends StatelessWidget {
  const StartStopButton({
    super.key,
    required this.started,
    required this.startRace
  });

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
