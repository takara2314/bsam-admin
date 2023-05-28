import 'package:flutter/material.dart';

import 'package:bsam_admin/models/athlete.dart';

class AthletesArea extends StatelessWidget {
  const AthletesArea({
    Key? key,
    required this.markNames,
    required this.athletes,
    required this.forcePassed
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final List<Athlete> athletes;
  final Function(String, int) forcePassed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: width * 0.9,
      child: Column(
        children: [
          for (final athlete in athletes)
            AthleteItem(
              markNames: markNames,
              athlete: athlete,
              forcePassed: forcePassed
            )
        ]
      )
    );
  }
}

class AthleteItem extends StatelessWidget {
  const AthleteItem({
    Key? key,
    required this.markNames,
    required this.athlete,
    required this.forcePassed
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final Athlete athlete;
  final Function(String, int) forcePassed;

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
            AthleteInfo(
              markNames: markNames,
              athlete: athlete
            ),
            AthleteForceManageArea(
              markNames: markNames,
              athlete: athlete,
              forcePassed: forcePassed
            )
          ]
        )
      )
    );
  }
}

class AthleteInfo extends StatelessWidget {
  const AthleteInfo({
    Key? key,
    required this.markNames,
    required this.athlete
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          athlete.userId!,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold
          )
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            athlete.nextMarkNo != -1 ? '${markNames[athlete.nextMarkNo!]![0]}マークの案内中' : '',
            style: const TextStyle(
              fontSize: 16
            )
          )
        )
      ]
    );
  }
}

class AthleteForceManageArea extends StatelessWidget {
  const AthleteForceManageArea({
    Key? key,
    required this.markNames,
    required this.athlete,
    required this.forcePassed
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final Athlete athlete;
  final Function(String, int) forcePassed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {forcePassed(athlete.userId!, 1);},
          child: const Text('上通過')
        ),
        TextButton(
          onPressed: () {forcePassed(athlete.userId!, 2);},
          child: const Text('サイド通過')
        ),
        TextButton(
          onPressed: () {forcePassed(athlete.userId!, 3);},
          child: const Text('下通過')
        ),
      ],
    );
  }
}
