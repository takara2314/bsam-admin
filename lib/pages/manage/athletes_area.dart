import 'package:flutter/material.dart';
import 'dart:math';
import 'package:bsam_admin/components/battery_and_acc.dart';
import 'package:bsam_admin/models/athlete.dart';
import 'package:bsam_admin/utils/name.dart';

class AthletesArea extends StatelessWidget {
  const AthletesArea({
    Key? key,
    required this.markNames,
    required this.athletes,
    required this.forcePassed,
    required this.cancelPassed
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final List<Athlete> athletes;
  final Function(String, int) forcePassed;
  final Function(String, int) cancelPassed;

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
              forcePassed: forcePassed,
              cancelPassed: cancelPassed,
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
    required this.forcePassed,
    required this.cancelPassed
  }) : super(key: key);

  final Map<int, List<String>> markNames;
  final Athlete athlete;
  final Function(String, int) forcePassed;
  final Function(String, int) cancelPassed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: width * 0.9,
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Transform.rotate(
              angle: athlete.compassDeg! * pi / 180,
              child: const Icon(
                Icons.navigation,
                color: Color.fromARGB(255, 255, 127, 53),
                size: 30
              )
            )
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    convShowableName(athlete.userId!),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    )
                  )
                )
              ),
              BatteryAndAcc(
                batteryLevel: athlete.batteryLevel!,
                acc: athlete.location!.acc!
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 249, 215, 212),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Text(
                  athlete.nextMarkNo != -1 ? '${markNames[athlete.nextMarkNo!]![2]}${markNames[athlete.nextMarkNo!]![0]}マークを案内中' : '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary
                  )
                )
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {cancelPassed(athlete.userId!, athlete.nextMarkNo!);},
                    child: const Text(
                      '通過取り消し',
                      style: TextStyle(
                        fontSize: 12
                      )
                    )
                  ),
                  TextButton(
                    onPressed: () {forcePassed(athlete.userId!, athlete.nextMarkNo!);},
                    child: const Text(
                      '次のマークを案内',
                      style: TextStyle(
                        fontSize: 12
                      )
                    )
                  )
                ]
              )
            ]
          )
        ]
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
