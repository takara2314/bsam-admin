import 'package:flutter/material.dart';

class RaceNameArea extends StatelessWidget {
  const RaceNameArea({
    super.key,
    required this.raceName
  });

  final String raceName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(raceName)
    );
  }
}
