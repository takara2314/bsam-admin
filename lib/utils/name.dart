import 'dart:core';

String convShowableName(String userId) {
  RegExp regexAthlete = RegExp(r'^athlete([0-9]+)$');
  final group = regexAthlete.firstMatch(userId);

  if (group != null) {
    return '${group.group(1)}番艇';
  }

  return userId;
}
